classdef TestPermOscillationEffect < matlab.unittest.TestCase
    % TestPermOscillationEffect
    %
    % Unit test suite for the PermOscillationEffect class.
    %
    % This test suite verifies the correct identification of
    % permanent oscillation signals and the rejection of signals
    % that do not exhibit oscillatory behavior.
    %
    % The test suite currently covers:
    %   - Recognition of a valid permanent oscillation signal.
    %   - Rejection of a constant signal.

    methods (Test)

        function testValidSignal(testCase)
            % TESTVALIDSIGNAL Verifies the recognition of a valid
            % permanent oscillation signal.
            %
            % A synthetic sinusoidal signal is generated using
            % known model parameters. The effect detector must
            % successfully recognize the signal through model fitting.

            % Arrange
            t = (1:1200)';
            trueParams = [3, 0, 2*pi/120, 0, 2];

            opt = PermOscillationOptions();
            opt.params0(3) = trueParams(3);
            opt.useSpectralCheck = false;
            opt.betaTol = 1e-5;

            effect = PermOscillationEffect();
            effect.setOptions(opt);

            model = effect.getModel();
            y = model(trueParams, t);

            % Act
            result = effect.analyze(y, t);
            context = effect.getContext();

            % Assert
            testCase.verifyTrue(result);
            testCase.verifyGreaterThan(context.fitExitFlag, 0);
            testCase.verifyGreaterThan(context.R2, opt.threshold);
        end

        function testConstantSignal(testCase)
            % TESTCONSTANTSIGNAL Verifies that a constant signal
            % is rejected because it does not exhibit oscillatory
            % behavior.
            %
            % The analysis must reject the signal without accepting
            % the DC component of its spectrum as an oscillation.

            % Arrange
            t = (1:600)';
            y = 2 * ones(size(t));

            opt = PermOscillationOptions();

            effect = PermOscillationEffect();
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