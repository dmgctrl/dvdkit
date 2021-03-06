

#define OSReadBigInt8(x, y)     (((uint8_t*)x)[y])
#define OSWriteBigInt8(x, y, z) (void)(((uint8_t*)x)[y] = z)

#define kDKMaxSectorsPerVOBFile ((1024L * 1024L * 1024L) / 2048L)
#define kDKMaxSectorsPerVOBSet  (9 * kDKMaxSectorsPerVOBFile)


typedef struct video_attr_t video_attr_t;
struct video_attr_t {
    uint16_t 
#if BYTE_ORDER == LITTLE_ENDIAN
    allow_automatic_letterbox : 1,
    allow_automatic_panandscan : 1,
    display_aspect_ratio : 2,
    video_format : 2,
    mpeg_version : 2,
    /**/
    film_mode : 1,
    letterboxed : 1,
    picture_size : 2,
    /**/
    bit_rate : 1,
    __zero_1 : 1,
    line21_cc_2 : 1,
    line21_cc_1 : 1;
#else
    mpeg_version : 2,
    video_format : 2,
    display_aspect_ratio : 2,
    allow_automatic_panandscan : 1,
    allow_automatic_letterbox : 1,
    /**/
    line21_cc_1 : 1,
    line21_cc_2 : 1,
    __zero_1 : 1,
    bit_rate : 1,
    /**/
    picture_size : 2,
    letterboxed : 1,
    film_mode : 1;
#endif
} __attribute__ ((packed));

typedef struct audio_attr_t audio_attr_t;
struct audio_attr_t {
    uint16_t
#if BYTE_ORDER == LITTLE_ENDIAN
    application_mode : 2,
    lang_type : 2,
    multichannel_extension : 1,
    audio_format : 3,
    /**/
    channels : 3,
    __zero_1 : 1,
    sample_frequency : 2,
    quantization : 2;
#else
    audio_format : 3,
    multichannel_extension : 1,
    lang_type : 2,
    application_mode : 2,
    /**/
    quantization : 2,
    sample_frequency : 2,
    __zero_1 : 1,
    channels : 3;
#endif
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t code_extension;
    uint8_t __zero_2;
    union {
        uint8_t value;
        struct {
            uint8_t
#if BYTE_ORDER == LITTLE_ENDIAN
            mode : 1,
            mc_intro : 1,
            version : 2,
            channel_assignment : 3,
            __zero_1 : 1;
#else
            __zero_1 : 1,
            channel_assignment : 3,
            version : 2,
            mc_intro : 1,
            mode : 1;
#endif
        } __attribute__ ((packed)) karaoke;
        struct {
            uint8_t
#if BYTE_ORDER == LITTLE_ENDIAN
            __zero_1 : 3,
            dolby_encoded : 1,
            __zero_2 : 4;
#else
            __zero_2 : 4,
            dolby_encoded : 1,
            __zero_1 : 3;
#endif
        } __attribute__ ((packed)) surround;
    } __attribute__ ((packed)) app_info;
} __attribute__ ((packed));

typedef struct subp_attr_t subp_attr_t;
struct subp_attr_t {
    uint8_t
#if BYTE_ORDER == LITTLE_ENDIAN
    lang_type : 2,
    __zero_1 : 3,
    code_mode : 3;
#else
    code_mode : 3,
    __zero_1 : 3,
    lang_type : 2;
#endif
    uint8_t __zero_2;
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t code_extension;
} __attribute__ ((packed));

typedef struct multichannel_ext_t multichannel_ext_t;
struct multichannel_ext_t {
    uint8_t
#if BYTE_ORDER == LITTLE_ENDIAN
    ach0_gme : 1,
    __zero_1 : 7,
	
    ach1_gme : 1,
    __zero_2 : 7,
	
    ach2_gm2e : 1,
    ach2_gm1e : 1,
    ach2_gv2e : 1,
    ach2_gv1e : 1,
    __zero_3 : 4,
	
    ach3_se2e : 1,
    ach3_gmAe : 1,
    ach3_gv2e : 1,
    ach3_gv1e : 1,
    __zero_4 : 4,
	
    ach4_seBe : 1,
    ach4_gmBe : 1,
    ach4_gv2e : 1,
    ach4_gv1e : 1,
    __zero_5 : 4;
#else
    __zero_1 : 7,
    ach0_gme : 1,
	
    __zero_2 : 7,
    ach1_gme : 1,
	
    __zero_3 : 4,
    ach2_gv1e : 1,
    ach2_gv2e : 1,
    ach2_gm1e : 1,
    ach2_gm2e : 1,
	
    __zero_4 : 4,
    ach3_gv1e : 1,
    ach3_gv2e : 1,
    ach3_gmAe : 1,
    ach3_se2e : 1,
	
    __zero_5 : 4,
    ach4_gv1e : 1,
    ach4_gv2e : 1,
    ach4_gmBe : 1,
    ach4_seBe : 1;
#endif
    uint8_t __zero_6[19];
} __attribute__ ((packed));

typedef struct vmgi_mat_t vmgi_mat_t;
struct vmgi_mat_t {
    uint8_t vmg_identifier[12];
    uint32_t vmg_last_sector;
    uint8_t __zero_1[12];
    uint32_t vmgi_last_sector;
    uint16_t specification_version;
    uint32_t vmg_category;
    uint16_t vmg_nr_of_volumes;
    uint16_t vmg_this_volume_nr;
    uint8_t disc_side;
    uint8_t __zero_3[19];
    uint16_t vmg_nr_of_title_sets;
    uint8_t provider_identifier[32];
    uint64_t vmg_pos_code;
    uint8_t __zero_4[24];
    uint32_t vmgi_last_byte;
    uint32_t first_play_pgc;
    uint8_t __zero_5[56];
    /**/
    uint32_t vmgm_vobs;
    /**/
    uint32_t tt_srpt;           
    uint32_t vmgm_pgci_ut;      
    uint32_t ptl_mait;
    uint32_t vmg_vts_atrt;
    uint32_t txtdt_mgi;         
    uint32_t vmgm_c_adt;        
    uint32_t vmgm_vobu_admap;   
    /**/
    uint8_t __zero_6[32];
    video_attr_t vmgm_video_attr;
    uint16_t nr_of_vmgm_audio_streams;
    audio_attr_t vmgm_audio_attr[8];
    uint8_t __zero_8[16];
    uint16_t nr_of_vmgm_subp_streams;
    subp_attr_t vmgm_subp_attr;
    uint8_t __zero_9[164];
} __attribute__ ((packed));

typedef struct vts_mat_t vts_mat_t;
struct vts_mat_t {                      //  Offset
                                        //  -----
    uint8_t vts_identifier[12];         //  0x000
    uint32_t vts_last_sector;           //  0x00C
    uint8_t __zero_1[12];               //  0x010
    uint32_t vtsi_last_sector;          //  0x01C
    uint16_t specification_version;     //  0x020
    uint32_t vts_category;              //  0x022
    uint8_t __zero_2[90];               //  0x026
    uint32_t vtsi_last_byte;            //  0x080
    uint8_t __zero_3[60];               //  0x084
    /**/
    uint32_t vtsm_vobs;                 //  0x0C0
    uint32_t vtstt_vobs;                //  0x0C4
    /**/
    uint32_t vts_ptt_srpt;              //  0x0C8
    uint32_t vts_pgcit;                 //  0x0CC
    uint32_t vtsm_pgci_ut;              //  0x0D0
    uint32_t vts_tmapt;                 //  0x0D4
    uint32_t vtsm_c_adt;                //  0x0D8
    uint32_t vtsm_vobu_admap;           //  0x0DC
    uint32_t vts_c_adt;                 //  0x0E0
    uint32_t vts_vobu_admap;            //  0x0E4
    /**/
    uint8_t __zero_4[24];               //  0x0E8
    /**/
    video_attr_t vtsm_video_attr;       //  0x100
    uint16_t nr_of_vtsm_audio_streams;  //  0x102
    audio_attr_t vtsm_audio_attr[8];    //  0x104
    uint8_t __zero_6[16];               //  0x144
    uint16_t nr_of_vtsm_subp_streams;   //  0x154
    subp_attr_t vtsm_subp_attr;         //  0x156
    uint8_t __zero_7[164];          
    /**/   	 
    video_attr_t vts_video_attr;
    uint16_t nr_of_vts_audio_streams;
    audio_attr_t vts_audio_attr[8];
    uint8_t __zero_8[16];
    uint16_t nr_of_vts_subp_streams;
    subp_attr_t vts_subp_attr[32];
    uint8_t __zero_9[2];
    multichannel_ext_t vts_mu_audio_attr[8];
} __attribute__ ((packed));

typedef struct tt_srpt_t tt_srpt_t;
struct tt_srpt_t {
    uint16_t nr_of_srpts;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct title_info_t title_info_t;
struct title_info_t {
    DKPlaybackFlags pb_ty;
    uint8_t nr_of_angles;
    uint16_t nr_of_ptts;
    uint16_t parental_id;
    uint8_t title_set_nr;
    uint8_t vts_ttn;
    uint32_t title_set_sector;
} __attribute__ ((packed));

typedef struct vmgi_pgci_ut_t vmgm_pgci_ut_t;
struct vmgi_pgci_ut_t {
    uint16_t nr_of_lus;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct vtsm_pgci_ut_t vtsm_pgci_ut_t;
struct vtsm_pgci_ut_t {
    uint16_t nr_of_lus;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct vtsm_lu_t vtsm_lu_t;
struct vtsm_lu_t {
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t exists;
    uint32_t pgcit_start_byte;
} __attribute__ ((packed));

typedef struct vmgm_lu_t vmgm_lu_t;
struct vmgm_lu_t {
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t exists;
    uint32_t pgcit_start_byte;
} __attribute__ ((packed));

typedef struct vtsm_pgc_t vtsm_pgc_t;
struct vtsm_pgc_t {
    uint16_t nr_of_pgci_srp;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct vmgm_pgc_t vmgm_pgc_t;
struct vmgm_pgc_t {
    uint16_t nr_of_pgci_srp;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct pgci_srp_t pgci_srp_t;
struct pgci_srp_t {
    uint8_t  entry_id;
#if BYTE_ORDER == LITTLE_ENDIAN
    unsigned int unknown1   : 4;
    unsigned int block_type : 2;
    unsigned int block_mode : 2;
#else
    unsigned int block_mode : 2;
    unsigned int block_type : 2;
    unsigned int unknown1   : 4;
#endif  
    uint16_t ptl_id_mask;
    uint32_t pgc_start_byte;
} __attribute__ ((packed));

typedef struct c_adt_t c_adt_t;
struct c_adt_t {
    uint16_t nr_of_vob_ids;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct cell_adr_t cell_adr_t;
struct cell_adr_t {
    uint16_t vob_id;
    uint8_t cell_id;
    uint8_t __zero_1;
    uint32_t start_sector;
    uint32_t last_sector;
} __attribute__ ((packed));

typedef struct vts_atrt_t vmg_vts_atrt_t;
struct vts_atrt_t {
    uint16_t nr_of_vtss;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct ptl_mait_t ptl_mait_t;
struct ptl_mait_t {
    uint16_t nr_of_countries;
    uint16_t nr_of_vtss;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct cell_playback_flags_t cell_playback_flags_t;
struct cell_playback_flags_t {
    uint16_t
#if BYTE_ORDER == LITTLE_ENDIAN
    seamless_angle : 1,
    stc_discontinuity: 1,
    interleaved : 1,
    seamless_play : 1,
    block_type : 2,
    block_mode : 2,
    /**/    
    __zero_1 : 6,
    restricted : 1,
    playback_mode : 1;
#else
    block_mode : 2,
    block_type : 2,
    seamless_play : 1,
    interleaved : 1,
    stc_discontinuity: 1,
    seamless_angle : 1,
    /**/
    playback_mode : 1,
    restricted : 1,
    __zero_1 : 6;
#endif
};

typedef struct cell_playback_t cell_playback_t;
struct cell_playback_t {
    cell_playback_flags_t flags;
    uint8_t still_time;
    uint8_t cell_cmd_nr;
    DKTime playback_time;
    uint32_t first_sector;
    uint32_t first_ilvu_end_sector;
    uint32_t last_vobu_start_sector;
    uint32_t last_sector;
} __attribute__ ((packed));

typedef struct pgc_t pgc_t;
struct pgc_t {
    uint16_t __zero_1;
    uint8_t nr_of_programs;
    uint8_t nr_of_cells;
    DKTime playback_time;
    DKUserOperationFlags prohibited_ops;
    uint16_t audio_control[8]; /* New type? */
    uint32_t subp_control[32]; /* New type? */
    uint16_t next_pgc_nr;
    uint16_t prev_pgc_nr;
    uint16_t goup_pgc_nr;
    uint8_t pg_playback_mode;
    uint8_t still_time;
    uint32_t palette[16]; /* New type struct {zero_1, Y, Cr, Cb} ? */
    uint16_t command_tbl_offset;
    uint16_t program_map_offset;
    uint16_t cell_playback_offset;
    uint16_t cell_position_offset;
} __attribute__ ((packed));

typedef struct cell_position_t cell_position_t;
struct cell_position_t {
    uint16_t vob_id_nr;
    uint8_t  __zero_1;
    uint8_t  cell_nr;
} __attribute__ ((packed));

typedef struct vts_ptt_srpt_t vts_ptt_srpt_t;
struct vts_ptt_srpt_t {
    uint16_t nr_of_srpts;
    uint16_t zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct ptt_info_t ptt_info_t;
struct ptt_info_t {
    uint16_t pgcn;
    uint16_t pgn;
} __attribute__ ((packed));

typedef struct vts_tmapti_t vts_tmapti_t;
struct vts_tmapti_t {
    uint16_t nr_of_pgcs;
    uint16_t __zero_1;
    uint32_t last_byte;
};


@interface DKVirtualMachine (DVDCommand)
- (uint16_t) registerForCode:(uint8_t)rn;
- (void) setValue:(uint16_t)value forRegisterForCode:(uint8_t)rn;
- (void) conditionallySetHighlightedButton:(uint8_t)btn;
- (void) executeLinkSubset:(uint8_t)code;
@end

@interface DKCommand (Private)
- (int) executeComparison:(uint8_t)comparison value1:(uint16_t)value1 value2:(uint16_t)value2;
- (uint16_t) computeOp:(uint8_t)op value1:(uint16_t)value1 value2:(uint16_t)value2;
@end

#define DKLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, nil, [NSBundle bundleForClass:[DKVirtualMachine class]], comment)

extern NSString* const kDVDKitErrorDomain;

typedef enum {
    kDKMultipleErrorsError,
    /**/
    kDKNumberOfVolumesError,
    kDKVolumeNumberError,
    kDKDiscSideError,
    kDKNumberOfTitleSetsError,
    kDKFirstPlayProgramChainError,
    kDKTitleTrackSearchPointerTableError,
    kDKMenuProgramChainInformationMapError,
    kDKMenuCellAddressTableError,
    kDKCellAddressTableError,
    kDKNumberOfVideoAttributesError,
    kDKNumberOfAudioStreamsError,
    kDKNumberOfSubpictureAttributesError,
    kDKNumberOfSubpictureStreamsError,
    kDKNumberOfMenuProgramChainLanguageUnitsError,
    kDKTitleSetProgramChainInformationMapError,
    kDKPartOfTitleSearchPointerTableError,
    kDKSectionNameError,
    kDKVobuAddressTableError,
    kDKTitleSetAttributeTableError,
} DKErrorCode;

#define DKErrorWithCode(code, ...)   __DKErrorWithCode(code, self, NSAffectedObjectsErrorKey, [NSString stringWithUTF8String:__PRETTY_FUNCTION__], @"function", [NSNumber numberWithInt:__LINE__], @"line", __VA_ARGS__)
extern NSError* __DKErrorWithCode(DKErrorCode code, ...);

@interface NSObject (DVDKit_Private)
+ (CFBitVectorRef) _readVobuAddressMapFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
+ (NSMutableData*) _saveVobuAddressMap:(CFBitVectorRef)vobuAddressMap errors:(NSMutableArray*)errors;


@end
