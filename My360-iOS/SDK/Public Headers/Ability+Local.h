//
//  Ability+Local.h
//  AnyPresence SDK
//

/*!
 @header Ability+Local
 @abstract Local category for Ability class
 */

#import "Ability.h"

/*!
 @category Ability (Local)
 @abstract Adds local query capabilities to Ability.
 @discussion Serves as a strongly-typed wrapper around @link //apple_ref/occ/cat/APObject(Local) @/link methods.
 */ 
@interface Ability (Local)

/*!
 @method allLocalWithOffset:limit:
 @abstract Fetches objects matching query scope "all" from local cache, with pagination.
 @param offset Number of objects to skip.
 @param limit Maximum number of objects to fetch.
 @result Array of objects.
 */
+ (NSArray *)allLocalWithOffset:(NSUInteger)offset limit:(NSUInteger)limit;

/*!
 @method exactMatchLocalWithParams:offset:limit:
 @abstract Fetches objects matching query scope "exact_match" from local cache, with pagination.
 @param params Scope parameter - params.
 @param offset Number of objects to skip.
 @param limit Maximum number of objects to fetch.
 @result Array of objects.
 */
+ (NSArray *)exactMatchLocalWithParams:(NSDictionary *)params offset:(NSUInteger)offset limit:(NSUInteger)limit;

/*!
 @method activeAbilitiesLocalWithAppId:offset:limit:
 @abstract Fetches objects matching query scope "active_abilities" from local cache, with pagination.
 @param appId Scope parameter - appId.
 @param offset Number of objects to skip.
 @param limit Maximum number of objects to fetch.
 @result Array of objects.
 */
+ (NSArray *)activeAbilitiesLocalWithAppId:(NSNumber *)appId offset:(NSUInteger)offset limit:(NSUInteger)limit;

@end