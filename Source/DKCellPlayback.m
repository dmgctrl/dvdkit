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

NSString* const DVDCellPlaybackException = @"DVDCellPlayback";

@implementation DKCellPlayback
@synthesize blockType;
@synthesize blockMode;
@synthesize firstSector;
@synthesize lastSector;
@synthesize firstInterleavingUnitSector;
@synthesize lastVideoObjectUnitStartSector;
@synthesize postCommandIndex;
@synthesize playbackTime;
@synthesize stillTime;
@synthesize userInfo;

+ (id) cellPlaybackWithData:(NSData*)data
{
    return [[[DKCellPlayback alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data, @"Shouldn't be nil");
    NSAssert([data length] == sizeof(cell_playback_t), @"Must be 24 bytes.");
    if (self = [super init]) {
        const cell_playback_t* cell_playback = [data bytes];

        /*  The bit-flags are defined in an endian-neutral manner.
         */
        seamless_angle = cell_playback->flags.seamless_angle;
        stc_discontinuity = cell_playback->flags.stc_discontinuity;
        interleaved = cell_playback->flags.interleaved;
        seamless_play = cell_playback->flags.seamless_play;
        blockType = cell_playback->flags.block_type;
        blockMode = cell_playback->flags.block_mode;
        restricted = cell_playback->flags.restricted;
        playback_mode = cell_playback->flags.playback_mode;

        /* dvd_time_t is endian-neutral.
         */
        playbackTime = cell_playback->playback_time;

        /*  Pick out the values of fields that are endian-sensitive.
         */
        stillTime = OSReadBigInt8(&cell_playback->still_time, 0);
        postCommandIndex = OSReadBigInt8(&cell_playback->cell_cmd_nr, 0);
        firstSector = OSReadBigInt32(&cell_playback->first_sector, 0);
        firstInterleavingUnitSector = OSReadBigInt32(&cell_playback->first_ilvu_end_sector, 0);
        lastVideoObjectUnitStartSector = OSReadBigInt32(&cell_playback->last_vobu_start_sector, 0);
        lastSector = OSReadBigInt32(&cell_playback->last_sector, 0);

        /*  Sanity checking.
         */
        // TODO: Replace the exceptions with error objects.
#if 0
        if (firstInterleavingUnitSector > lastVideoObjectUnitStartSector) {
            [NSException raise:DVDCellPlaybackException format:@"%s(%d)", __FILE__, __LINE__];
        } else if (lastVideoObjectUnitStartSector > lastSector) {
            [NSException raise:DVDCellPlaybackException format:@"%s(%d)", __FILE__, __LINE__];
        }
#endif
    }
    return self;
}

- (void) dealloc
{
    [userInfo release], userInfo = nil;
    [super dealloc];
}

- (NSData*) saveAsData:(NSError**)error
{
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(cell_playback_t)];
    cell_playback_t* cell_playback = [data mutableBytes];

    cell_playback->flags.seamless_angle = seamless_angle;
    cell_playback->flags.stc_discontinuity = stc_discontinuity;
    cell_playback->flags.interleaved = interleaved;
    cell_playback->flags.seamless_play = seamless_play;
    cell_playback->flags.block_type = blockType;
    cell_playback->flags.block_mode = blockMode;
    cell_playback->flags.restricted = restricted;
    cell_playback->flags.playback_mode = playback_mode;
    
    /* dvd_time_t is endian-neutral.
     */
    cell_playback->playback_time = playbackTime;
    
    /*  Pick out the values of fields that are endian-sensitive.
     */
    OSWriteBigInt8(&cell_playback->still_time, 0, stillTime);
    OSWriteBigInt8(&cell_playback->cell_cmd_nr, 0, postCommandIndex);
    OSWriteBigInt32(&cell_playback->first_sector, 0, firstSector);
    OSWriteBigInt32(&cell_playback->first_ilvu_end_sector, 0, firstInterleavingUnitSector);
    OSWriteBigInt32(&cell_playback->last_vobu_start_sector, 0, lastVideoObjectUnitStartSector);
    OSWriteBigInt32(&cell_playback->last_sector, 0, lastSector);
    
    return data;
}

- (BOOL) isEqual:(DKCellPlayback*)anObject
{
    if (self == anObject) {
        return YES;
    } else return (
        [self class] == [anObject class]
        && anObject->seamless_angle == seamless_angle
        && anObject->stc_discontinuity == stc_discontinuity
        && anObject->interleaved == interleaved
        && anObject->seamless_play == seamless_play
        && anObject->blockType == blockType
        && anObject->blockMode == blockMode
        && anObject->restricted == restricted
        && anObject->playback_mode == playback_mode
        && 0 == memcmp(&anObject->playbackTime, &playbackTime, sizeof(playbackTime))
        && anObject->stillTime == stillTime
        && anObject->postCommandIndex == postCommandIndex
        && anObject->firstSector == firstSector
        && anObject->firstInterleavingUnitSector == firstInterleavingUnitSector
        && anObject->lastVideoObjectUnitStartSector == lastVideoObjectUnitStartSector
        && anObject->lastSector == lastSector
    );
}

@end
