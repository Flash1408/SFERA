classdef TestDivOscillationEffect < matlab.unittest.TestCase
    % TestDivOscillationEffect
    %
    % Unit test suite for the DivOscillationEffect class.
    %
    % This test suite verifies the correct identification of
    % divergent oscillation signals and the rejection of signals
    % that do not exhibit the required oscillatory behavior.
    %
    % The test suite currently covers:
    %   - Recognition of a valid divergent oscillation signal.
    %   - Rejection of a constant signal.

    methods (Test)

        function testValidSignal(testCase)
            % TESTVALIDSIGNAL Verifies the recognition of a valid
            % divergent oscillation signal.
            %
            % A synthetic exponentially increasing sinusoidal signal
            % is generated using known model parameters. The effect
            % detector must successfully recognize the signal through
            % nonlinear model fitting.

            % Arrange
            t = (1:1200)';
            trueParams = [1, 0.001, 2*pi/120, 0.3];

            opt = DivOscillationOptions();

            effect = DivOscillationEffect();
            effect.setOptions(opt);

            model = effect.getModel();
            y = model(trueParams, t);

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(result);
            testCase.verifyGreaterThan(context.fitExitFlag, 0);
            testCase.verifyGreaterThan(context.params_fit(2), 0);
            testCase.verifyGreaterThan(context.R2, opt.threshold);
        end

        function testConstantSignal(testCase)
            % TESTCONSTANTSIGNAL Verifies that a constant signal
            % is rejected because it does not exhibit oscillatory
            % behavior.
            %
            % The preliminary peak validation must reject the signal
            % and prevent the nonlinear fitting stage from executing.

            % Arrange
            t = (1:600)';
            y = 2 * ones(size(t));

            opt = DivOscillationOptions();

            effect = DivOscillationEffect();
            effect.setOptions(opt);

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyFalse(result);
            testCase.verifyFalse(context.result);
            testCase.verifyFalse(context.fitEligible);
        end

    end
end
