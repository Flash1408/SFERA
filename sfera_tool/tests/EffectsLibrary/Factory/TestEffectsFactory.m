classdef TestEffectsFactory < matlab.unittest.TestCase
    % TestEffectsFactory
    %
    % Unit tests for the EffectsFactory class.
    %
    % These tests verify the creation and configuration of predefined
    % effects, as well as the creation of custom effects.

    methods (Test)
        function testCreatePredefinedEffects(testCase)
            % TESTCREATEPREDEFINEDEFFECTS Verifies that the factory
            % creates all predefined effects with the correct options.

            effectNames = {
                'Exponential Divergence'
                'Damped Oscillations'
                'Permanent Oscillations'
                'Divergent Oscillations'
                'Sum of Sinusoids'
                'Runge Trend'
                'Arctangent Trend'
                'Cubic Radix Trend'
                'Fifth Radix Trend'
                };

            expectedEffects = {
                'ExpEffect'
                'DampedOscillationEffect'
                'PermOscillationEffect'
                'DivOscillationEffect'
                'MultiSinusoidsEffect'
                'RungeEffect'
                'ArcTanEffect'
                'CubicRadixEffect'
                'FifthRadixEffect'
                };

            expectedOptions = {
                'ExpOptions'
                'DampedOscillationOptions'
                'PermOscillationOptions'
                'DivOscillationOptions'
                'MultiSinusoidsOptions'
                'RungeOptions'
                'ArcTanOptions'
                'CubicRadixOptions'
                'FifthRadixOptions'
                };

            for k = 1:numel(effectNames)
                effect = EffectsFactory.createEffect(effectNames{k});

                testCase.verifyClass(effect, expectedEffects{k});

                % Execute the effect to retrieve its analysis context.
                t = linspace(0, 1, 100)';
                y = 1 + 0.5 * exp(2 * t);

                effect.analyze(y, t);
                context = effect.getContext();

                testCase.verifyClass(context.options, expectedOptions{k});
            end
        end


        function testUnknownEffectName(testCase)
            % TESTUNKNOWNEFFECTNAME Verifies that the factory rejects
            % effect names that are not supported.

            testCase.verifyError( ...
                @() EffectsFactory.createEffect('Unknown Effect'), ...
                'EffectsFactory:UnknownEffect');
        end


        function testInvalidEffectName(testCase)
            % TESTINVALIDEFFECTNAME Verifies that the factory rejects
            % effect names with an unsupported data type.

            testCase.verifyError( ...
                @() EffectsFactory.createEffect(123), ...
                'EffectsFactory:InvalidEffectName');
        end


        function testCreateCustomEffect(testCase)
            % TESTCREATECUSTOMEFFECT Verifies that the factory correctly
            % creates a CustomEffect from a UserModel and CustomOptions.

            userModel = UserModel();

            userModel.modelFunction = @(params, t) ...
                params(1) .* exp(params(2) .* t);

            userModel.initialParams = [1, 1];
            userModel.lb = [0, -10];
            userModel.ub = [10, 10];

            userModel.modelName = "Custom Exponential";
            userModel.description = "A simple exponential model.";

            options = CustomOptions();
            options.params0 = userModel.initialParams;
            options.lb = userModel.lb;
            options.ub = userModel.ub;

            effect = EffectsFactory.createCustomEffect( ...
                userModel, options);

            testCase.verifyClass(effect, 'CustomEffect');
        end
    end
end
