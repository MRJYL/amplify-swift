//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import AWSCognitoIdentity
@testable import Amplify
@testable import AWSCognitoAuthPlugin
import AWSCognitoIdentityProvider
import ClientRuntime

class AWSAuthSignInPluginTests: BasePluginTest {

    override var initialState: AuthState {
        AuthState.configured(.signedOut(.init(lastKnownUserName: nil)), .configured)
    }

    /// Test a signIn with valid inputs
    ///
    /// - Given: Given an auth plugin with mocked service.
    ///
    /// - When:
    ///    - I invoke signIn with valid values
    /// - Then:
    ///    - I should get a .done response
    ///
    func testSuccessfulSignIn() async {
        let clientMetadata = ["somekey": "somevalue"]
        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { input in
            XCTAssertEqual(clientMetadata, input.clientMetadata)
            return InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { input in
            XCTAssertEqual(clientMetadata, input.clientMetadata)
            return RespondToAuthChallengeOutput(
                authenticationResult: .init(
                    accessToken: Defaults.validAccessToken,
                    expiresIn: 300,
                    idToken: "idToken",
                    newDeviceMetadata: nil,
                    refreshToken: "refreshToken",
                    tokenType: ""),
                challengeName: .none,
                challengeParameters: [:],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(metadata: clientMetadata)
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)

        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .done = result.nextStep else {
                XCTFail("Result should be .done for next step")
                return
            }
            XCTAssertTrue(result.isSignedIn, "Signin result should be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with valid inputs and authflow type
    ///
    /// - Given: Given an auth plugin with mocked service.
    ///
    /// - When:
    ///    - I invoke signIn with valid values
    /// - Then:
    ///    - I should get a .done response
    ///
    func testSuccessfulSignInWithAuthFlow() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .init(
                    accessToken: Defaults.validAccessToken,
                    expiresIn: 300,
                    idToken: "idToken",
                    newDeviceMetadata: nil,
                    refreshToken: "refreshToken",
                    tokenType: ""),
                challengeName: .none,
                challengeParameters: [:],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(
            metadata: ["somekey": "somevalue"],
            authFlowType: .userSRP
        )
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)

        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .done = result.nextStep else {
                XCTFail("Result should be .done for next step")
                return
            }
            XCTAssertTrue(result.isSignedIn, "Signin result should be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with empty username
    ///
    /// - Given: Given an auth plugin with mocked service.
    ///
    /// - When:
    ///    - I invoke signIn with empty username
    /// - Then:
    ///    - I should get a .validation error
    ///
    func testSignInWithEmptyUsername() async {

        self.mockIdentityProvider = MockIdentityProvider()

        let options = AuthSignInRequest.Options()

        do {
            let result = try await plugin.signIn(username: "", password: "password", options: options)
            XCTFail("Should not receive a success response \(result)")
        } catch {
            guard case AuthError.validation = error else {
                XCTFail("Should receive validation error instead got \(error)")
                return
            }
        }
    }

    /// Test a signIn with empty password
    ///
    /// - Given: Given an auth plugin with mocked service.
    ///
    /// - When:
    ///    - I invoke signIn with no password
    /// - Then:
    ///    - I should get a valid response
    ///
    func testSignInWithEmptyPassword() async {

        self.mockIdentity = MockIdentity(
            mockGetIdResponse: getId,
            mockGetCredentialsResponse: getCredentials)

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .init(
                    accessToken: Defaults.validAccessToken,
                    expiresIn: 300,
                    idToken: "idToken",
                    newDeviceMetadata: nil,
                    refreshToken: "refreshToken",
                    tokenType: ""),
                challengeName: .none,
                challengeParameters: [:],
                session: "session")
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "", options: options)
            guard case .done = result.nextStep else {
                XCTFail("Result should be .done for next step")
                return
            }
            XCTAssertTrue(result.isSignedIn, "Signin result should be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with nil as reponse from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mock nil response from service
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .unknown error
    ///
    func testSignInWithInvalidResult() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput()
        })
        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not receive a success response \(result)")
        } catch {
            guard case AuthError.service = error else {
                XCTFail("Should receive unknown error instead got \(error)")
                return
            }
        }
    }

    /// Test a signIn with nil as reponse from service followed by a second signIn with a valid response
    ///
    /// - Given: Given an auth plugin with mocked service. Mock nil response from service followed by a valid response
    ///
    /// - When:
    ///    - I invoke signIn a second time
    /// - Then:
    ///    - I should get signed in
    ///
    func testSecondSignInAfterSignInWithInvalidResult() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput()
        })
        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not receive a success response \(result)")
        } catch {
            self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
                InitiateAuthOutput(
                    authenticationResult: .none,
                    challengeName: .passwordVerifier,
                    challengeParameters: InitiateAuthOutput.validChalengeParams,
                    session: "someSession")
            }, mockRespondToAuthChallengeResponse: { _ in
                RespondToAuthChallengeOutput(
                    authenticationResult: .init(
                        accessToken: Defaults.validAccessToken,
                        expiresIn: 300,
                        idToken: "idToken",
                        newDeviceMetadata: nil,
                        refreshToken: "refreshToken",
                        tokenType: ""),
                    challengeName: .none,
                    challengeParameters: [:],
                    session: "session")
            })

            do {
                let result2 = try await plugin.signIn(username: "username", password: "password", options: options)
                XCTAssertTrue(result2.isSignedIn, "Signin result should be complete")
            } catch {
                XCTFail("Received failure with error \(error)")
            }
        }
    }

    /// Test a signIn with smsMFA as signIn result response
    ///
    /// - Given: Given an auth plugin with mocked service. Mock smsMFA response for signIn result
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .confirmSignInWithSMSMFACode
    ///
    func testSignInWithNextStepSMS() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .smsMfa,
                challengeParameters: [:],
                session: "session")
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithSMSMFACode = result.nextStep else {
                XCTFail("Result should be .confirmSignInWithSMSMFACode for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with additional info in next step
    ///
    /// - Given: Given an auth plugin with mocked service. Mock additional info in custom auth
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a the info in next step
    ///
    func testCustomAuthWithAdditionalInfo() async {

        let clientMetadata = ["somekey": "somevalue"]
        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { input in
            XCTAssertEqual(clientMetadata, input.clientMetadata)
            return InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { input in
            XCTAssertEqual(clientMetadata, input.clientMetadata)
            return RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .customChallenge,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(
            metadata: clientMetadata,
            authFlowType: .customWithSRP
        )
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithCustomChallenge(let additionalInfo) = result.nextStep else {
                XCTFail("Result should be .confirmSignInWithCustomChallenge for next step")
                return
            }
            guard let addditionalValue = additionalInfo?["paramKey"] else {
                XCTFail("Additional info should be passed to the result")
                return
            }
            XCTAssertEqual(addditionalValue, "value", "Additional info should be same")
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with additional info in next step
    ///
    /// - Given: Given an auth plugin with mocked service. Mock additional info in sms mfa
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a the info in next step
    ///
    func testSMSMFAWithAdditionalInfo() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .smsMfa,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithSMSMFACode(_, let additionalInfo) = result.nextStep else {
                XCTFail("Result should be .confirmSignInWithSMSMFACode for next step")
                return
            }
            guard let addditionalValue = additionalInfo?["paramKey"] else {
                XCTFail("Additional info should be passed to the result")
                return
            }
            XCTAssertEqual(addditionalValue, "value", "Additional info should be same")
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with newPassword as signIn result response
    ///
    /// - Given: Given an auth plugin with mocked service. Mock newPassword response for signIn result
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .confirmSignInWithNewPassword error
    ///
    func testSignInWithNextStepNewPassword() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .newPasswordRequired,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let options = AuthSignInRequest.Options()

        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithNewPassword = result.nextStep else {
                XCTFail("Result should be .confirmSignInWithNewPassword for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with additional info in next step
    ///
    /// - Given: Given an auth plugin with mocked service. Mock additional info in new password
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a the info in next step
    ///
    func testNewPasswordWithAdditionalInfo() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .newPasswordRequired,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithNewPassword(let additionalInfo) = result.nextStep else {
                XCTFail("Result should be .confirmSignInWithNewPassword for next step")
                return
            }
            guard let addditionalValue = additionalInfo?["paramKey"] else {
                XCTFail("Additional info should be passed to the result")
                return
            }
            XCTAssertEqual(addditionalValue, "value", "Additional info should be same")
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with customChallenge as signIn result response
    ///
    /// - Given: Given an auth plugin with mocked service. Mock customChallenge response for signIn result
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .confirmSignInWithCustomChallenge
    ///
    func testSignInWithNextStepCustomChallenge() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .customChallenge,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(authFlowType: .customWithSRP)
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithCustomChallenge = result.nextStep else {
                XCTFail("Result should be .confirmSignInWithCustomChallenge for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with invalid response
    ///
    /// - Given: Given an auth plugin with mocked service. Mock unknown response for signIn result
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .unknown error
    ///
    func testSignInWithNextStepUnknown() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .sdkUnknown("no idea"),
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.unknown = error else {
                XCTFail("Should produce unknown error")
                return
            }
        }
    }

    /// Test a signIn with deviceSRP response
    ///
    /// - Given: Given an auth plugin with mocked service. Mock unknown response for signIn result
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error, because the response doesn't return valid data
    ///
    func testSignInWithNextDeviceSRP() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .deviceSrpAuth,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .devicePasswordVerifier,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(
            metadata: ["somekey": "somevalue"],
            authFlowType: .userPassword
        )
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)
        do {
            let result = try await plugin.signIn(
                username: "username",
                password: "password",
                options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service = error else {
                XCTFail("Should produce as service error")
                return
            }
        }
    }

    /// Test a signIn with customAuthWIthoutSRP
    ///
    /// - Given: An auth plugin with mocked service. Returning a new challenge after confirm sign in is called
    ///
    /// - When:
    ///    - I invoke signIn and then confirm sign in
    /// - Then:
    ///    - The next step smsMfA should be triggered
    ///
    func testSignInWithCustomAuthIncorrectCode() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .customChallenge,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .smsMfa,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(
            metadata: ["somekey": "somevalue"],
            authFlowType: .customWithoutSRP
        )
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)
        do {
            let result = try await plugin.signIn(
                username: "username",
                password: "password",
                options: options)
            guard case .confirmSignInWithCustomChallenge = result.nextStep,
                  case let confirmSignInResult = try await plugin.confirmSignIn(
                    challengeResponse: "245234"
                  ),
                  case .confirmSignInWithSMSMFACode = confirmSignInResult.nextStep
            else {
                return XCTFail("Incorrect challenge type")
            }
        } catch {
            XCTFail("Should not fail with \(error)")
        }
    }


    func testSignInWithNextStepTOTP() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .softwareTokenMfa,
                challengeParameters: ["paramKey": "value"],
                session: "session")
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithTOTPCode = result.nextStep else {
                XCTFail("Result should be .confirmSignInWithTOTPCode for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Should not produce error")
        }
    }

    func testSignInWithNextStepSelectMFAType() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .selectMfaType,
                challengeParameters: ["MFAS_CAN_CHOOSE": "[\"SMS_MFA\",\"SOFTWARE_TOKEN_MFA\"]"],
                session: "session")
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .continueSignInWithMFASelection(let allowedMFaTypes) = result.nextStep else {
                XCTFail("Result should be .continueSignInWithMFASelection for next step")
                return
            }
            XCTAssertTrue(!allowedMFaTypes.isEmpty, "Allowed MFA types should have TOTP and SMS")
            XCTAssertEqual(allowedMFaTypes, Set([MFAType.sms, MFAType.totp]))
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Should not produce error")
        }
    }

    func testSignInWithNextStepSetupMFA() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .mfaSetup,
                challengeParameters: ["MFAS_CAN_SETUP": "[\"SMS_MFA\",\"SOFTWARE_TOKEN_MFA\"]"],
                session: "session")
        }, mockAssociateSoftwareTokenResponse: { _ in
                return .init(secretCode: "123456", session: "session")
        } )

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .continueSignInWithTOTPSetup(let totpSetupDetails) = result.nextStep else {
                XCTFail("Result should be .continueSignInWithTOTPSetup for next step")
                return
            }
            XCTAssertNotNil(totpSetupDetails)
            XCTAssertEqual(totpSetupDetails.sharedSecret, "123456")
            XCTAssertEqual(totpSetupDetails.username, "username")
        } catch {
            XCTFail("Should not produce error")
        }
    }

    func testSignInWithNextStepSetupMFAWithUnavailableMFAType() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .mfaSetup,
                challengeParameters: ["MFAS_CAN_SETUP": "[\"SMS_MFA\"]"],
                session: "session")
        }, mockAssociateSoftwareTokenResponse: { _ in
            return .init(secretCode: "123456", session: "session")
        } )

        let options = AuthSignInRequest.Options()
        do {
            _ = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not continue as MFA type is not available for setup")
        } catch {
            guard case AuthError.service = error else {
                XCTFail("Should produce as service error")
                return
            }
        }
    }

    // MARK: - Service error for initiateAuth

    /// Test a signIn with `InternalErrorException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   InternalErrorException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .unknown error
    ///
    func testSignInWithInternalErrorException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.InternalErrorException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.unknown = error else {
                XCTFail("Should produce unknown error")
                return
            }
        }
    }

    /// Test a signIn with `InvalidLambdaResponseException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   InvalidLambdaResponseException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .lambda error
    ///
    func testSignInWithInvalidLambdaResponseException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.InvalidLambdaResponseException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .lambda = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce lambda error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `InvalidParameterException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   InvalidParameterException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .invalidParameter error
    ///
    func testSignInWithInvalidParameterException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.InvalidParameterException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .invalidParameter = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce invalidParameter error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `InvalidUserPoolConfigurationException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   InvalidUserPoolConfigurationException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .configuration error
    ///
    func testSignInWithInvalidUserPoolConfigurationException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.InvalidUserPoolConfigurationException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.configuration = error else {
                XCTFail("Should produce configuration intead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `NotAuthorizedException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   NotAuthorizedException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .notAuthorized error
    ///
    func testSignInWithNotAuthorizedException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.NotAuthorizedException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.notAuthorized = error else {
                XCTFail("Should produce notAuthorized error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `PasswordResetRequiredException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   PasswordResetRequiredException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .resetPassword as next step
    ///
    func testSignInWithPasswordResetRequiredException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.PasswordResetRequiredException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .resetPassword = result.nextStep else {
                XCTFail("Result should be .resetPassword for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Should not produce error - \(error)")
        }
    }

    /// Test a signIn with `PasswordResetRequiredException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   PasswordResetRequiredException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .resetPassword as next step
    ///
    func testSignInWithPasswordResetRequiredException2() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw try await AWSCognitoIdentityProvider.PasswordResetRequiredException(
                httpResponse: .init(body: .none, statusCode: .badRequest),
                decoder: nil,
                message: nil,
                requestID: nil
            )
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .resetPassword = result.nextStep else {
                XCTFail("Result should be .resetPassword for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Should not produce error - \(error)")
        }
    }

    /// Test a signIn with `ResourceNotFoundException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   ResourceNotFoundException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .resourceNotFound error
    ///
    func testSignInWithResourceNotFoundException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.ResourceNotFoundException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .resourceNotFound = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce resourceNotFound error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `TooManyRequestsException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   TooManyRequestsException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .requestLimitExceeded error
    ///
    func testSignInWithTooManyRequestsException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.TooManyRequestsException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .requestLimitExceeded = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce requestLimitExceeded error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `UnexpectedLambdaException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   UnexpectedLambdaException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .lambda error
    ///
    func testSignInWithUnexpectedLambdaException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.UnexpectedLambdaException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .lambda = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce lambda error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `UserLambdaValidationException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   UserLambdaValidationException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .lambda error
    ///
    func testSignInWithUserLambdaValidationException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.UserLambdaValidationException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .lambda = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce lambda error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `UserNotConfirmedException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   UserNotConfirmedException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .confirmSignUp as next step
    ///
    func testSignInWithUserNotConfirmedException() async {
        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.UserNotConfirmedException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignUp = result.nextStep else {
                XCTFail("Result should be .confirmSignUp for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Should not produce error - \(error)")
        }
    }

    /// Test a signIn with `UserNotConfirmedException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   UserNotConfirmedException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .confirmSignUp as next step
    ///
    func testSignInWithUserNotConfirmedException2() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw try await AWSCognitoIdentityProvider.UserNotConfirmedException(
                httpResponse: .init(body: .none, statusCode: .badRequest)
            )
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignUp = result.nextStep else {
                XCTFail("Result should be .confirmSignUp for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn, "Signin result should not be complete")
        } catch {
            XCTFail("Should not produce error - \(error)")
        }
    }

    /// Test a signIn with `UserNotFoundException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   UserNotFoundException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .userNotFound error
    ///
    func testSignInWithUserNotFoundException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            throw AWSCognitoIdentityProvider.UserNotFoundException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .userNotFound = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce userNotFound error but instead produced \(error)")
                return
            }
        }
    }

    // MARK: - Service error for RespondToAuthChallenge

    /// Test a signIn with `AliasExistsException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   AliasExistsException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .aliasExists error
    ///
    func testSignInWithAliasExistsException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            throw AWSCognitoIdentityProvider.AliasExistsException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .aliasExists = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce aliasExists error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn with `InvalidPasswordException` from service
    ///
    /// - Given: Given an auth plugin with mocked service. Mocked service should mock a
    ///   InvalidPasswordException response for signIn
    ///
    /// - When:
    ///    - I invoke signIn
    /// - Then:
    ///    - I should get a .service error with .invalidPassword error
    ///
    func testSignInWithInvalidPasswordException() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            throw AWSCognitoIdentityProvider.InvalidPasswordException()
        })

        let options = AuthSignInRequest.Options()
        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Should not produce result - \(result)")
        } catch {
            guard case AuthError.service(_, _, let underlyingError) = error,
                  case .invalidPassword = (underlyingError as? AWSCognitoAuthError) else {
                XCTFail("Should produce invalidPassword error but instead produced \(error)")
                return
            }
        }
    }

    /// Test a signIn restart while another sign in is in progress
    ///
    /// - Given: Given an auth plugin with mocked service and a in progress signIn waiting for SMS verification
    ///
    /// - When:
    ///    - I invoke another signIn with valid values
    /// - Then:
    ///    - I should get a .done response
    ///
    func testRestartSignIn() async {

        self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .none,
                challengeName: .smsMfa,
                challengeParameters: [:],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(metadata: ["somekey": "somevalue"])
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)

        do {
            let result = try await plugin.signIn(username: "username", password: "password", options: options)
            guard case .confirmSignInWithSMSMFACode =  result.nextStep else {
                XCTFail("Result should be .confirmSignInWithSMSMFACode for next step")
                return
            }
            XCTAssertFalse(result.isSignedIn)
            self.mockIdentityProvider = MockIdentityProvider(mockInitiateAuthResponse: { _ in
                InitiateAuthOutput(
                    authenticationResult: .none,
                    challengeName: .passwordVerifier,
                    challengeParameters: InitiateAuthOutput.validChalengeParams,
                    session: "someSession")
            }, mockRespondToAuthChallengeResponse: { _ in
                RespondToAuthChallengeOutput(
                    authenticationResult: .init(
                        accessToken: Defaults.validAccessToken,
                        expiresIn: 300,
                        idToken: "idToken",
                        newDeviceMetadata: nil,
                        refreshToken: "refreshToken",
                        tokenType: ""),
                    challengeName: .none,
                    challengeParameters: [:],
                    session: "session")
            })
            let result2 = try await plugin.signIn(username: "username2", password: "password", options: options)
            guard case .done =  result2.nextStep else {
                XCTFail("Result should be .confirmSignInWithSMSMFACode for next step")
                return
            }
            XCTAssertTrue(result2.isSignedIn)
        } catch {
            XCTFail("Received failure with error \(error)")
        }
    }

    /// Test a signIn with valid inputs
    ///
    /// - Given: Given an auth plugin with mocked service.
    ///
    /// - When:
    ///    - I invoke signIn with valid values, and
    ///      AuthN is success whereas AuthZ fails
    ///      In This case, GetId throws an exception
    /// - Then:
    ///    - I should get a service exception and should not be signed in
    ///
    func testSuccessfulSignInWithFailingIdentity() async {

        self.mockIdentity = MockIdentity(
            mockGetIdResponse: { _ in
                throw AWSCognitoIdentity.InvalidParameterException(
                    message: "Invalid parameter passed"
                )
            },
            mockGetCredentialsResponse: getCredentials)

        self.mockIdentityProvider = MockIdentityProvider(mockRevokeTokenResponse: { _ in
            RevokeTokenOutput()
        }, mockInitiateAuthResponse: { _ in
            InitiateAuthOutput(
                authenticationResult: .none,
                challengeName: .passwordVerifier,
                challengeParameters: InitiateAuthOutput.validChalengeParams,
                session: "someSession")
        }, mockRespondToAuthChallengeResponse: { _ in
            RespondToAuthChallengeOutput(
                authenticationResult: .init(
                    accessToken: Defaults.validAccessToken,
                    expiresIn: 300,
                    idToken: "idToken",
                    newDeviceMetadata: nil,
                    refreshToken: "refreshToken",
                    tokenType: ""),
                challengeName: .none,
                challengeParameters: [:],
                session: "session")
        })

        let pluginOptions = AWSAuthSignInOptions(metadata: ["somekey": "somevalue"])
        let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)

        do {
            _ = try await plugin.signIn(username: "username", password: "password", options: options)
            XCTFail("Sign In with failing authorization should throw an error")

        } catch AuthError.service(_, _, let error) {
            guard let cognitoError = error as? AWSCognitoAuthError else {
                XCTFail("Underlying error should be of type AWSCognitoAuthError")
                return
            }

            guard case AWSCognitoAuthError.invalidParameter = cognitoError else {
                XCTFail("Error thrown should be an AWSCognitoAuthError.invalidParameter")
                return
            }

        } catch {
            XCTFail("Error thrown should be an AuthError but got:\n\(error)")
        }
    }
}
