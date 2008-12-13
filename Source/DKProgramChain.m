/*
 * Copyright (C) 2008 Jason Allum
 *               2008 RipItApp.com
 * 
 * This file is part of DVDKit, an Objective-C DVD player emulation toolkit. 
 * 
 * DVDKit is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * DVDKit is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
 *
 */
#import "DVDKit.h"
#import "DVDKit+Private.h"

NSString* const DVDProgramChainException = @"DVDProgramChain";

@implementation DKProgramChain
@synthesize prohibitedUserOperations;
@synthesize preCommands;
@synthesize cellCommands;
@synthesize postCommands;
@synthesize programMap;
@synthesize cellPlaybackTable;
@synthesize nextProgramChainNumber;
@synthesize previousProgramChainNumber;
@synthesize goUpProgramChainNumber;

static NSArray* NO_ELEMENTS;

+ (void) initialize
{
    if (self == [DKProgramChain class]) {
        NO_ELEMENTS = [[NSArray alloc] init];
    }
}

+  programChainWithData:(NSData*)data
{
    return [[[DKProgramChain alloc] initWithData:data] autorelease];
}

- initWithData:(NSData*)data
{
    if (self = [super init]) {
        const uint8_t* bytes = [data bytes];
        if (0 != OSReadBigInt16(bytes, 0)) {
            [NSException raise:DVDProgramChainException format:@"%s(%d)", __FILE__, __LINE__];
        }

        uint8_t nr_of_programs = bytes[2];
        uint8_t nr_of_cells = bytes[3];
        memcpy(&playback_time, bytes + 4, sizeof(DKTime));
        memcpy(&prohibitedUserOperations, bytes + 8, sizeof(prohibitedUserOperations));
        
        if (nr_of_cells < nr_of_programs) {
            [NSException raise:DVDProgramChainException format:@"%s(%d)", __FILE__, __LINE__];
        }

        for (int i = 0; i < 8; i++) {
            audio_control[i] = OSReadBigInt16(bytes, 12 + (i << 1));
        }
        
        for (int i = 0; i < 32; i++) {
            subp_control[i] = OSReadBigInt32(bytes, 28 + (i << 2));
        }
        
        nextProgramChainNumber = OSReadBigInt16(bytes, 156);
        previousProgramChainNumber = OSReadBigInt16(bytes, 158);
        goUpProgramChainNumber = OSReadBigInt16(bytes, 160);
        still_time = bytes[162];
        pg_playback_mode = bytes[163];
        
        for (int i = 0; i < 16; i++) {
            palette[i] = OSReadBigInt32(bytes, 164 + (i << 2));
        }
        
        uint16_t command_tbl_offset = OSReadBigInt16(bytes, 228);
        uint16_t program_map_offset = OSReadBigInt16(bytes, 230);
        uint16_t cell_playback_offset = OSReadBigInt16(bytes, 232);
        uint16_t cell_position_offset = OSReadBigInt16(bytes, 234);

        if (!nr_of_programs) {
            if (still_time || pg_playback_mode || program_map_offset || cell_playback_offset || cell_position_offset) {
#ifdef STRICT
                [NSException raise:DVDProgramChainException format:@"%s(%d)", __FILE__, __LINE__];
#else
                still_time = pg_playback_mode = program_map_offset = cell_playback_offset = cell_position_offset = 0;
#endif
            }
        } else {
            if (!program_map_offset || !cell_playback_offset || !cell_position_offset) {
                [NSException raise:DVDProgramChainException format:@"%s(%d)", __FILE__, __LINE__];
            }
        }

        preCommands = (id)NO_ELEMENTS; 
        postCommands = (id)NO_ELEMENTS;
        cellCommands = (id)NO_ELEMENTS;
        if (command_tbl_offset != 0) {
            const uint8_t* p = bytes + command_tbl_offset;
            uint16_t nr_of_pre_commands = OSReadBigInt16(p, 0); 
            uint16_t nr_of_post_commands = OSReadBigInt16(p, 2); 
            uint16_t nr_of_cell_commands = OSReadBigInt16(p, 4); 
            uint16_t last_byte = OSReadBigInt16(p, 6); 
            
            if (((8 + (8 * (nr_of_pre_commands + nr_of_post_commands + nr_of_cell_commands)))-1) > last_byte) {
                [NSException raise:DVDProgramChainException format:@"%s(%d)", __FILE__, __LINE__];
            }
            p += 8;
            
            if (nr_of_pre_commands) {
                preCommands = [NSMutableArray arrayWithCapacity:nr_of_pre_commands]; 
                int row = 0;
                while (nr_of_pre_commands--) {
                    [preCommands addObject:[DKCommand commandWith64Bits:OSReadBigInt64(p, 0) row:row]];
                    p += 8;
                    row++;
                }
            }
            if (nr_of_post_commands) {
                postCommands = [NSMutableArray arrayWithCapacity:nr_of_post_commands];
                int row = 0;
                while (nr_of_post_commands--) {
                    [postCommands addObject:[DKCommand commandWith64Bits:OSReadBigInt64(p, 0) row:row]];
                    p += 8;
                    row++;
                }
            }
            if (nr_of_cell_commands) {
                cellCommands = [NSMutableArray arrayWithCapacity:nr_of_cell_commands];
                int row = 0;
                while (nr_of_cell_commands--) {
                    [cellCommands addObject:[DKCommand commandWith64Bits:OSReadBigInt64(p, 0) row:row]];
                    p += 8;
                    row++;
                }
            }
        }

        if (program_map_offset) {
            programMap = [NSMutableArray arrayWithCapacity:nr_of_programs];
            for (int i = 0; i < nr_of_programs; i++) {
                [programMap addObject:[NSNumber numberWithInt:bytes[program_map_offset + i]]];
            }
        }

        if (!cell_playback_offset || !nr_of_cells) {
            cellPlaybackTable = (id)NO_ELEMENTS;
        } else {
            cellPlaybackTable = [NSMutableArray arrayWithCapacity:nr_of_cells];
            for (const uint8_t* p = bytes + cell_playback_offset, *lp = p + (nr_of_cells * 24); p < lp; p += 24) {
                [cellPlaybackTable addObject:[DKCellPlayback cellPlaybackWithData:[data subdataWithRange:NSMakeRange(p - bytes, 24)]]];
            }
        }
        
        if (!cell_position_offset || !nr_of_cells) {
            cellPositionTable = (id)NO_ELEMENTS;
        } else {
            cellPositionTable = [NSMutableArray arrayWithCapacity:nr_of_cells];
            for (const uint8_t* p = bytes + cell_position_offset, *lp = p + (nr_of_cells * 4); p < lp; p += 4) {
                uint16_t vob_id_nr = OSReadBigInt16(p, 0);
                uint8_t cell_nr = p[3];                
                [cellPositionTable addObject:[DKCellPosition cellPositionWithNumber:cell_nr vobId:vob_id_nr]];
            }
        }

        [preCommands retain];
        [postCommands retain];
        [cellCommands retain];
        [cellPlaybackTable retain];
        [cellPositionTable retain];
        [programMap retain];
    }
    return self;
}

- (void) dealloc
{
    [programMap release];
    [preCommands release];
    [postCommands release];
    [cellCommands release];
    [cellPlaybackTable release];
    [cellPositionTable release];
    [super dealloc];
}

- (NSData*) saveAsData:(NSError**)error
{
    NSMutableArray* errors = !error ? nil : [NSMutableArray array];
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(pgc_t)];
    pgc_t pgc;
    bzero(&pgc, sizeof(pgc_t));

    memcpy((uint8_t*)&pgc.playback_time, &playback_time, sizeof(DKTime));
    memcpy((uint8_t*)&pgc.prohibited_ops, &prohibitedUserOperations, sizeof(DKUserOperationFlags));
    
    for (int i = 0; i < 8; i++) {
        OSWriteBigInt16(&pgc.audio_control, i << 1, audio_control[i]);
    }
    
    for (int i = 0; i < 32; i++) {
        OSWriteBigInt32(&pgc.subp_control, (i << 2), subp_control[i]);
    }
    
    OSWriteBigInt16(&pgc.next_pgc_nr, 0, nextProgramChainNumber);
    OSWriteBigInt16(&pgc.prev_pgc_nr, 0, previousProgramChainNumber);
    OSWriteBigInt16(&pgc.goup_pgc_nr, 0, goUpProgramChainNumber);
    OSWriteBigInt8(&pgc.still_time, 0, still_time);
    OSWriteBigInt8(&pgc.pg_playback_mode, 0, pg_playback_mode);

    for (int i = 0; i < 16; i++) {
        OSWriteBigInt32(&pgc.palette, (i << 2), palette[i]);
    }
    
    uint16_t nr_of_pre_commands = [preCommands count];
    uint16_t nr_of_post_commands = [postCommands count];
    uint16_t nr_of_cell_commands = [cellCommands count];
    if (nr_of_pre_commands || nr_of_post_commands || nr_of_cell_commands) {
        uint16_t command_tbl_offset = [data length];
        OSWriteBigInt16(&pgc.command_tbl_offset, 0, command_tbl_offset);

        //  TODO: Check for overflow.
        uint16_t last_byte = 8 + (8 * (nr_of_pre_commands + nr_of_post_commands + nr_of_cell_commands));
        [data increaseLengthBy:last_byte];
        uint8_t* base = [data mutableBytes] + command_tbl_offset;

        OSWriteBigInt16(base, 0, nr_of_pre_commands);
        OSWriteBigInt16(base, 2, nr_of_post_commands);
        OSWriteBigInt16(base, 4, nr_of_cell_commands);
        OSWriteBigInt16(base, 6, last_byte - 1);

        uint16_t offset = 8;
        for (DKCommand* command in preCommands) {
            OSWriteBigInt64(base, offset, command.bits);
            offset += 8;
        }
        for (DKCommand* command in postCommands) {
            OSWriteBigInt64(base, offset, command.bits);
            offset += 8;
        }
        for (DKCommand* command in cellCommands) {
            OSWriteBigInt64(base, offset, command.bits);
            offset += 8;
        }
    }
    
    uint8_t nr_of_programs = [programMap count];
    if (nr_of_programs) {
        uint16_t program_map_offset = [data length];
        OSWriteBigInt8(&pgc.nr_of_programs, 0, nr_of_programs);
        OSWriteBigInt16(&pgc.program_map_offset, 0, program_map_offset);
        [data increaseLengthBy:nr_of_programs];
        uint8_t* base = [data mutableBytes] + program_map_offset;
        for (int i = 0; i < nr_of_programs; i++) {
            OSWriteBigInt8(base, i, [[programMap objectAtIndex:i] unsignedCharValue]);
        }
    }
    
    uint8_t nr_of_cells = [cellPlaybackTable count];
    if (nr_of_cells) {
        OSWriteBigInt8(&pgc.nr_of_cells, 0, nr_of_cells);

        uint16_t cell_playback_offset = [data length];
        uint16_t cell_position_offset = cell_playback_offset + (nr_of_cells * sizeof(cell_playback_t));
        OSWriteBigInt16(&pgc.cell_playback_offset, 0, cell_playback_offset);
        OSWriteBigInt16(&pgc.cell_position_offset, 0, cell_position_offset);
        [data increaseLengthBy:nr_of_cells * (sizeof(cell_playback_t) + sizeof(cell_position_t))];
        uint8_t* base = [data mutableBytes] + cell_playback_offset;
        
        for (int i = 0; i < nr_of_cells; i++, base += sizeof(cell_playback_t)) {
            NSError* cellPlaybackError = nil;
            NSData* cellPlaybackData = [[cellPlaybackTable objectAtIndex:i] saveAsData:errors ? &cellPlaybackError : NULL];
            if (cellPlaybackError) {
                if (cellPlaybackError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[cellPlaybackError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:cellPlaybackError];
                }
            }
            if (cellPlaybackData) {
                memcpy(base, [cellPlaybackData bytes], sizeof(cell_playback_t));
            }
        }

        for (int i = 0; i < nr_of_cells; i++, base += sizeof(cell_position_t)) {
            NSError* cellPositionError = nil;
            NSData* cellPositionData = [[cellPositionTable objectAtIndex:i] saveAsData:errors ? &cellPositionError : NULL];
            if (cellPositionError) {
                if (cellPositionError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[cellPositionError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:cellPositionError];
                }
            }
            if (cellPositionData) {
                memcpy(base, [cellPositionData bytes], sizeof(cell_position_t));
            }
        }
    }
    
    if (errors) {
        int errorCount = [errors count];
        if (0 == errorCount) {
            *error = nil;
        } else if (1 == errorCount) {
            *error = [errors objectAtIndex:0];
        } else {
            *error = DKErrorWithCode(kDKMultipleErrorsError, errors, NSDetailedErrorsKey, nil);
        }
    }

    memcpy([data mutableBytes], &pgc, sizeof(pgc_t));
    return data;
}

@end
