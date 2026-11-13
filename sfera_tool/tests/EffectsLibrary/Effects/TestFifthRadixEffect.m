classdef TestFifthRadixEffect < matlab.unittest.TestCase
    % TestFifthRadixEffect
    %
    % Unit test suite for the FifthRadixEffect class.
    %
    % This test suite verifies the correct identification of fifth
    % radix signals and the behavior of the associated analysis
    % pipeline.
    %
    % The test suite currently covers:
    %   - Recognition of a valid fifth radix signal.

    methods (Test)
        function testValidSignal(testCase)
            % TESTVALIDSIGNAL Verifies the recognition of a valid
            % fifth radix signal.
            %
            % A synthetic signal is generated using known model
            % parameters. The effect detector must successfully
            % recognize the signal and achieve an R-squared value
            % above the configured acceptance threshold.

            % Arrange
            t = linspace(0, 1, 200)';
            trueParams = [2, 3, 0.4, 1];

            opt = FifthRadixOptions();
            effect = FifthRadixEffect();
            effect.setOptions(opt);

            model = effect.getModel();
            y = model(trueParams, t);

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(result);
            testCase.verifyGreaterThan(context.R2, opt.threshold);
        end
    end
end
