typedef struct {
    int offset;
    int length;
    int extra;
} MULIndexMetadata;

typedef struct {
    MULIndexMetadata metadata;
    NSData *data;
} IndexedMULEntry;

@interface IndexedMULReader : NSObject

-(instancetype)initWithDataFilename:(NSString *)dataFilename indexFilename:(NSString*) indexFilename;
-(instancetype)initWithDataFilename:(NSString *)dataFilename ofType:(NSString *)dataType indexFilename:(NSString *)indexFilename ofType:(NSString *)indexType;

-(IndexedMULEntry)getEntryForId:(NSUInteger)entryId;

@property (nonnull, nonatomic, readonly) NSFileHandle *dataHandle;
@property (nonnull, nonatomic, readonly) NSFileHandle *indexHandle;


@end
