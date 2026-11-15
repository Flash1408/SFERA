classdef TestRungeEffect < matlab.unittest.TestCase
    % TestRungeEffect
    %
    % Unit test suite for the RungeEffect class.
    %
    % This test suite verifies the correct identification of Runge
    % signals and the behavior of the associated analysis pipeline.
    %
    % The test suite currently covers:
    %   - Recognition of a valid Runge signal.
    %   - Rejection of signals associated with a constant time vector.

    methods (Test)
        function testValidSignal(testCase)
            % TESTVALIDSIGNAL Verifies the recognition of a valid
            % Runge signal.
            %
            % A synthetic signal is generated using known model
            % parameters. The effect detector must successfully
            % recognize the signal and achieve an R-squared value
            % above the configured acceptance threshold.

            % Arrange
            t = linspace(0, 1, 200)';
            trueParams = [2, 10, 0.5, 1];

            opt = RungeOptions();
            effect = RungeEffect();
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

        function testConstantTimeVector(testCase)
            % TESTCONSTANTTIMEVECTOR Verifies that a signal associated
            % with a constant time vector is rejected.
            %
            % A signal is analyzed using a time vector whose samples
            % are all identical. The analysis pipeline must reject
            % the input before attempting model fitting.

            % Arrange
            t = ones(200, 1);
            y = linspace(0, 1, 200)';

            opt = RungeOptions();
            effect = RungeEffect();
            effect.setOptions(opt);

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyFalse(result);
            testCase.verifyFalse(context.result);
            testCase.verifyEmpty(context.params_fit);
        end
    end
end
