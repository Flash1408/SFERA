classdef EffectsFactory
    % EffectsFactory
    %
    % Static factory responsible for creating and configuring
    % effect objects supported by the SFERA analysis framework.
    %
    % The factory maps the effect names used by the application
    % to their corresponding Effect and Options classes.
    %
    % Main responsibilities:
    %   - creating predefined effect objects
    %   - instantiating the corresponding options objects
    %   - assigning options to the created effects
    %   - creating custom effects from user-defined models
    %
    % The factory does not execute effect analysis.

    methods (Static)
        function names = getAvailableEffectNames()
            % GETAVAILABLEEFFECTNAMES Returns the names of predefined effects.
            %
            % OUTPUT:
            %   names -> Cell array containing the names of all predefined
            %            effects supported by the SFERA analysis framework.
            %
            % The returned names can be used by external components,
            % such as the EffectDetector and the graphical interface,
            % to identify the available predefined effects.
            %
            % The order represents the presentation order of the effects,
            % not necessarily their detection priority.

            names = {
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
        end

        function effect = createEffect(effectName)
            % CREATEEFFECT Creates a predefined effect.
            %
            % INPUT:
            %   effectName -> Name identifying the requested effect.
            %
            % OUTPUT:
            %   effect -> Configured instance of the corresponding
            %             concrete Effect class.
            %
            % An error is raised if the requested effect is unknown.

            % Validate the effect name.
            if ~(ischar(effectName) && isrow(effectName)) && ...
                    ~(isstring(effectName) && isscalar(effectName))
                error('EffectsFactory:InvalidEffectName', ...
                    'The effect name must be a character vector or string scalar.');
            end

            effectName = char(effectName);

            % Instantiate the corresponding effect and options.
            switch effectName
                case 'Exponential Divergence'
                    effect = ExpEffect();
                    options = ExpOptions();

                case 'Damped Oscillations'
                    effect = DampedOscillationEffect();
                    options = DampedOscillationOptions();

                case 'Permanent Oscillations'
                    effect = PermOscillationEffect();
                    options = PermOscillationOptions();

                case 'Divergent Oscillations'
                    effect = DivOscillationEffect();
                    options = DivOscillationOptions();

                case 'Sum of Sinusoids'
                    effect = MultiSinusoidsEffect();
                    options = MultiSinusoidsOptions();

                case 'Runge Trend'
                    effect = RungeEffect();
                    options = RungeOptions();

                case 'Arctangent Trend'
                    effect = ArcTanEffect();
                    options = ArcTanOptions();

                case 'Cubic Radix Trend'
                    effect = CubicRadixEffect();
                    options = CubicRadixOptions();

                case 'Fifth Radix Trend'
                    effect = FifthRadixEffect();
                    options = FifthRadixOptions();

                otherwise
                    error('EffectsFactory:UnknownEffect', ...
                        'Unknown effect name: %s.', effectName);
            end

            % Assign the corresponding configuration to the effect.
            effect.setOptions(options);
        end

        function effect = createCustomEffect(userModel, options)
            % CREATECUSTOMEFFECT Creates an effect from a user-defined model.
            %
            % INPUT:
            %   userModel -> UserModel object defining the custom model.
            %   options   -> CustomOptions object defining its configuration.
            %
            % OUTPUT:
            %   effect -> Configured CustomEffect instance.

            effect = CustomEffect(userModel, options);
        end
    end
end
