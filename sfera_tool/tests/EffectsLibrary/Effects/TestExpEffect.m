classdef TestExpEffect < matlab.unittest.TestCase
    % TestExpEffect
    %
    % Test class responsible for verifying the behavior of ExpEffect.
    %
    % This class contains unit tests for the exponential effect analysis,
    % checking both successful classifications and rejection cases.
    %
    % The tests also verify the correct handling of invalid input data
    % and optional analysis features.

    methods (Test)

        function testValidExponentialSignal(testCase)
            % testValidExponentialSignal
            %
            % Verifies that ExpEffect correctly identifies a valid exponential
            % signal.
            %
            % The test generates a synthetic signal using the exponential model
            % and checks whether the effect analysis successfully classifies it.

            % Arrange: generate a synthetic exponential signal.
            % Arrange: generate a synthetic decreasing exponential signal.
            t = (1:100)';
            y = 2 + 3*exp(-0.01*t);

            % Act: perform the exponential effect analysis.
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
            
            result = effect.analyze(y, t);

            % Assert: verify that the signal is classified as exponential.
            testCase.verifyTrue(result);
        end

        function testValidIncreasingExponentialSignal(testCase)
            % Verify recognition of an increasing exponential signal.
        
            t = (1:100)';
            y = 2 + 3*exp(0.01*t);
        
            effect = ExpEffect();
            effect.setOptions(ExpOptions());
        
            result = effect.analyze(y, t);
        
            testCase.verifyTrue(result);
        end

    end
end