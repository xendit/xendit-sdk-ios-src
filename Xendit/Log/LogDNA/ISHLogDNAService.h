//
//  ISHLogDNAService.h
//  ISHLogDNA
//
//  Created by Felix Lamouroux on 13.06.17.
//  Copyright © 2017 iosphere. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Default Meta Keys

extern NSString * const ISHLogDNAServiceKeyBundleShortVersion;
extern NSString * const ISHLogDNAServiceKeyBundleVersion;
extern NSString * const ISHLogDNAServiceKeyErrorCode;
extern NSString * const ISHLogDNAServiceKeyErrorDescription;
extern NSString * const ISHLogDNAServiceKeyErrorDomain;
extern NSString * const ISHLogDNAServiceKeyModelName;
extern NSString * const ISHLogDNAServiceKeySystemVersion;
extern NSString * const ISHLogDNAServiceKeyUnderlyingError;

#pragma mark - Log Levels

typedef NS_ENUM(NSUInteger, ISHLogDNALevel) {
    ISHLogDNALevelDebug,
    ISHLogDNALevelInfo,
    ISHLogDNALevelWarn,
    ISHLogDNALevelError,
    ISHLogDNALevelFatal,
};

#pragma mark - Message

/**
 *   A log message can be sent to LogDNA via the ISHLogDNAService.
 */
@interface ISHLogDNAMessage : NSObject

/**
 *   The line that will be logged.
 */
@property (nonatomic, readonly) NSString *line;

/**
 *   The timestamp of the creation of the message object.
 */
@property (nonatomic, readonly) NSDate *timestamp;

/**
 *   Meta data associated with the message. Contains user-defined
 *   entries and entries added by `messageWithLine:level:meta:`.
 *
 *   @sa messageWithLine:level:meta:
 */
@property (nonatomic, readonly) NSDictionary<NSString *, id> *meta;

/**
 *   The log level used for this message.
 */
@property (nonatomic, readonly) ISHLogDNALevel level;

/**
 *   Create messages using this constructor.
 *
 *   @param line The message line should not be empty.
 *   @param level The log level of this message.
 *   @param meta The optional meta field must be encodable into JSON using NSJSONSerialization.
 *
 *   @return An immutable timestamped message to be logged via the ISHLogDNAService.
 *
 *   @note You have to provide a consistent type per key across all messages' meta fields.
 *         If inconsistent value types are used, that line's metadata will not be parsed.
 *         For example, if a line is passed with a meta object, such as meta.myfield of type
 *         String, any subsequent lines with meta.myfield must have a String as its value type
 *         for meta.myfield.
 *
 *         This method will add the bundle's version (build number), short version, operating
 *         system version, and model identifer to meta automatically, but will never overwrite
 *         the given meta information if keys overlap.
 *
 *         Use the following keys to overwrite the respective information:
 *
 *              * ISHLogDNAServiceKeyBundleShortVersion
 *              * ISHLogDNAServiceKeyBundleVersion
 *              * ISHLogDNAServiceKeyModelName
 *              * ISHLogDNAServiceKeySystemVersion
 *
 */
+ (instancetype)messageWithLine:(NSString *)line level:(ISHLogDNALevel)level meta:(nullable NSDictionary<NSString *, id> *)meta;

/**
 *   Helper method to create meta entries from the given error.
 *
 *   Will set ISHLogDNAServiceKeyErrorDescription, ISHLogDNAServiceKeyErrorCode, and
 *   ISHLogDNAServiceKeyErrorDomain, if available.
 *
 *   Will add the same information for the recursive underlying errors
 *   (via ISHLogDNAServiceKeyUnderlyingError), if present.
 *
 *   Will return an empty dictionary if the error parameter was nil.
 */
+ (NSDictionary<NSString *, id> *)metaDictionaryWithError:(nullable NSError *)error;

/**
 *   @sa messageWithLine:level:meta:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 *   @sa messageWithLine:level:meta:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

#pragma mark - Service

/**
 *   This service provides remote logging methods via LogDNA.
 *
 *   Make sure to call +[ISHLogDNAService setupWithIngestionKey:hostName:appName:]
 *   before using any logging methods.
 */
@interface ISHLogDNAService : NSObject

/**
 *   Setup the ISHLogDNAService. Must be called before logging any messages.
 */
+ (instancetype)setupWithIngestionKey:(NSString *)key hostName:(NSString *)host appName:(NSString *)appName;

/**
 *   Sends an array of log messages to LogDNA. Make sure to setup the service before calling this method.
 */
+ (void)logMessages:(NSArray<ISHLogDNAMessage *> *)messages;

/**
 *   Log messages are only sent to the server if the service is enabled and will silently be ignored otherwise.
 *
 *   The default value is set to the user's advertising preferences, if AdSupport is available. Defaults to `NO`
 *   on other platforms.
 */
@property (class, nonatomic) BOOL enabled;

/**
 *   @sa setupWithIngestionKey:hostName:appName:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 *   @sa setupWithIngestionKey:hostName:appName:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
