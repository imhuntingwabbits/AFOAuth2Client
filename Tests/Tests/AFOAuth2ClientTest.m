//
//  AFOAuth2ClientTest.m
//  Wealthfront
//
//  Copyright (c) 2013 Wealthfront. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AFOAuth2Client.h"

@interface AFOAuth2Client (PrivateTestMethods)

@property(nonatomic, readonly) NSString *secret;

@end

@interface AFOAuth2ClientTest : XCTestCase

@end

@implementation AFOAuth2ClientTest

- (void)testInit {
  AFOAuth2Client *client = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:@"https://afnetworking.com"]
                                                          clientID:@"testClient"
                                                            secret:@"testSecret"];
  XCTAssertNotNil(client, @"Init failed?");
  XCTAssertTrue([client.baseURL isEqual:[NSURL URLWithString:@"https://afnetworking.com"]], @"Wrong url");
  XCTAssertTrue([client.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]], @"Wrong serializer");
  XCTAssertTrue([client.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]], @"Wrong serializer");
  XCTAssertTrue([client.clientID isEqualToString:@"testClient"], @"Wrong client id");
  XCTAssertTrue([client.secret isEqualToString:@"testSecret"], @"Wrong secret");
  XCTAssertTrue([client.serviceProviderIdentifier isEqualToString:@"afnetworking.com"], @"Wrong service provider");
}

- (void)testSetToken {
  AFOAuth2Client *client = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.wealthfront.com"]
                                                          clientID:@"testClient"
                                                            secret:@"testSecret"];
  id mockCredential = [OCMockObject mockForClass:[AFOAuthCredential class]];
  [[[mockCredential expect] andReturn:@"bearer"] tokenType];
  [[[mockCredential expect] andReturn:@"AccessToken"] accessToken];
  [client setAuthorizationHeaderWithCredential:mockCredential];
  XCTAssertTrue([[client.requestSerializer.HTTPRequestHeaders objectForKey:@"Authorization"] isEqualToString:@"Bearer AccessToken"], @"Wrong auth header value");
  
  [mockCredential verify];
}

- (void)testAuthMethods {
  AFOAuth2Client *client = [[AFOAuth2Client alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.wealthfront.com"]
                                                          clientID:@"testClient"
                                                            secret:nil];
  id mockClient = [OCMockObject partialMockForObject:client];
  [[mockClient expect] POST:@"auth"
                 parameters:@{@"grant_type": kAFOAuthPasswordCredentialsGrantType,
                              @"username": @"testUser",
                              @"password": @"testPass",
                              @"scope": @"testScope",
                              @"client_id": @"testClient"}
                    success:OCMOCK_ANY
                    failure:OCMOCK_ANY];
  [client authenticateUsingOAuthWithURLString:@"auth"
                                     username:@"testUser"
                                     password:@"testPass"
                                        scope:@"testScope"
                                      success:nil
                                      failure:nil];
  
  [[mockClient expect] POST:@"auth"
                 parameters:@{@"grant_type": kAFOAuthRefreshGrantType,
                              @"refresh_token": @"testRefresh",
                              @"client_id": @"testClient"}
                    success:OCMOCK_ANY
                    failure:OCMOCK_ANY];
  [client authenticateUsingOAuthWithURLString:@"auth"
                                 refreshToken:@"testRefresh"
                                      success:nil
                                      failure:nil];
  
  [[mockClient expect] POST:@"auth"
                 parameters:@{@"grant_type": kAFOAuthCodeGrantType,
                              @"code": @"testCode",
                              @"redirect_uri": @"testURI",
                              @"client_id": @"testClient"}
                    success:OCMOCK_ANY
                    failure:OCMOCK_ANY];
  [client authenticateUsingOAuthWithURLString:@"auth"
                                         code:@"testCode"
                                  redirectURI:@"testURI"
                                      success:nil
                                      failure:nil];
  
  [[mockClient expect] POST:@"auth"
                 parameters:@{@"grant_type": kAFOAuthClientCredentialsGrantType,
                              @"scope": @"testScope",
                              @"client_id": @"testClient"}
                    success:OCMOCK_ANY
                    failure:OCMOCK_ANY];
  [client authenticateUsingOAuthWithURLString:@"auth"
                                        scope:@"testScope"
                                      success:nil
                                      failure:nil];
  [mockClient verify];
}

- (void)testCredential {
  AFOAuthCredential *c = [AFOAuthCredential credentialWithOAuthToken:@"TestToken"
                                                           tokenType:@"TestType"];
  XCTAssertTrue([c.tokenType isEqualToString:@"TestType"], @"Wrong type");
  XCTAssertTrue([c.accessToken isEqualToString:@"TestToken"], @"Wrong token");
  XCTAssertNil(c.refreshToken, @"Should be nil");
  XCTAssertFalse(c.expired, @"Shouldn't be expired (no refresh token)");
  c = [[AFOAuthCredential alloc] initWithOAuthToken:@"TestToken"
                                          tokenType:@"TestType"];
  XCTAssertTrue([c.tokenType isEqualToString:@"TestType"], @"Wrong type");
  XCTAssertTrue([c.accessToken isEqualToString:@"TestToken"], @"Wrong token");
  XCTAssertNil(c.refreshToken, @"Should be nil");
  XCTAssertFalse(c.expired, @"Shouldn't be expired (no refresh token)");
  
  [c setRefreshToken:@"RefreshToken"
          expiration:[NSDate dateWithTimeIntervalSinceNow:20.0]];
  XCTAssertTrue([c.refreshToken isEqualToString:@"RefreshToken"], @"Wrong refresh token");
  XCTAssertFalse(c.expired, @"Shouldn't be expired");
  [c setRefreshToken:@"RefreshToken"
          expiration:[NSDate dateWithTimeIntervalSince1970:0]];
  XCTAssertTrue([c.refreshToken isEqualToString:@"RefreshToken"], @"Wrong refresh token");
  XCTAssertTrue(c.expired, @"Should be expired");
}

@end
