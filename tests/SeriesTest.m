classdef SeriesTest < matlab.unittest.TestCase
    
    properties(Access = private)
        Time, Temperature, Humidity, WindDirection, RainDrops, Raining
    end
    
    methods(TestMethodSetup)
        function setup(test)
            timestamps = [1529933525520; 1529933581618];
            test.Time = datetime(timestamps / 1000, 'ConvertFrom', 'posixtime');
            test.Temperature = [24.3; -3.5];
            test.Humidity = [60.7; 54.2];
            test.RainDrops = int64([123456789; -987654321]);
            test.WindDirection = {'north'; 'west'};
            test.Raining = [true; false];
        end
    end
    
    methods(Test, TestTags = {'unit'})
        function fails_when_empty_name(test)
            f = @() Series('').fields('temperature', 24.3).toLine();
            test.verifyError(f, 'toLine:emptyName');
        end
        
        function fails_when_empty_time(test)
            s = Series('weather') ...
                .fields('temperature', test.Temperature);
            test.verifyError(@() s.toLine(), 'toLine:emptyTime');
        end
        
        function allow_empty_time_for_single_samples(test)
            s = Series('weather') ...
                .fields('temperature', 24.3);
            exp = 'weather temperature=24.3';
            test.verifyEqual(s.toLine(), exp);
        end
        
        function when_empty_fields_return_empty(test)
            s = Series('weather');
            test.verifyEqual(s.toLine(), '');
        end
        
        function empty_fields_are_ignored(test)
            p = Series('weather') ...
                .fields('temperature', [], 'humidity', 60.7);
            exp = 'weather humidity=60.7';
            test.verifyEqual(p.toLine(), exp);
        end
        
        function empty_char_fields_are_not_ignored(test)
            p = Series('weather') ...
                .fields('temperature', 24.3, 'wind_dir', '');
            exp = 'weather temperature=24.3,wind_dir=""';
            test.verifyEqual(p.toLine(), exp);
        end
        
        function single_field(test)
            p = Series('weather') ...
                .fields('temperature', 24.3) ...
                .time(test.Time(1));
            exp = 'weather temperature=24.3 1529933525520';
            test.verifyEqual(p.toLine(), exp);
        end
        
        function single_field_array(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .fields('temperature', test.Temperature);
            exp = [ ...
                'weather temperature=24.3 1529933525520' newline ...
                'weather temperature=-3.5 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function supports_fields_with_integer_values(test)
            p = Series('weather') ...
                .time(test.Time) ...
                .fields('rain_drops', test.RainDrops);
            exp = [ ...
                'weather rain_drops=123456789i 1529933525520' newline ...
                'weather rain_drops=-987654321i 1529933581618'];
            test.verifyEqual(p.toLine(), exp);
        end
        
        function supports_fields_with_single_string_value(test)
            p = Series('weather') ...
                .fields('wind_direction', 'north-west') ...
                .time(test.Time(1));
            exp = 'weather wind_direction="north-west" 1529933525520';
            test.verifyEqual(p.toLine(), exp);
        end
        
        function supports_fields_with_cell_string_values(test)
            p = Series('weather') ...
                .time(test.Time) ...
                .fields('wind_direction', test.WindDirection);
            exp = [ ...
                'weather wind_direction="north" 1529933525520' newline ...
                'weather wind_direction="west" 1529933581618'];
            test.verifyEqual(p.toLine(), exp);
        end
        
        function supports_fields_with_logical_values(test)
            p = Series('weather') ...
                .time(test.Time) ...
                .fields('raining', test.Raining);
            exp = [ ...
                'weather raining=true 1529933525520' newline ...
                'weather raining=false 1529933581618'];
            test.verifyEqual(p.toLine(), exp);
        end
        
        function multiple_fields(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .fields('temperature', test.Temperature, 'humidity', test.Humidity);
            exp = [ ...
                'weather temperature=24.3,humidity=60.7 1529933525520' newline ...
                'weather temperature=-3.5,humidity=54.2 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function multiple_fields_from_struct(test)
            fields = struct( ...
                'temperature', test.Temperature, ...
                'humidity', test.Humidity);
            s = Series('weather') ...
                .time(test.Time) ...
                .fields(fields);
            exp = [ ...
                'weather temperature=24.3,humidity=60.7 1529933525520' newline ...
                'weather temperature=-3.5,humidity=54.2 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function supports_multiple_fields_calls(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .fields('temperature', test.Temperature) ...
                .fields('humidity', test.Humidity);
            exp = [ ...
                'weather temperature=24.3,humidity=60.7 1529933525520' newline ...
                'weather temperature=-3.5,humidity=54.2 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function single_tag(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .tags('city', 'barcelona') ...
                .fields('temperature', test.Temperature);
            exp = [ ...
                'weather,city=barcelona temperature=24.3 1529933525520' newline ...
                'weather,city=barcelona temperature=-3.5 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function multiple_tags(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .tags('city', 'barcelona', 'station', 'a1') ...
                .fields('temperature', test.Temperature);
            exp = [ ...
                'weather,city=barcelona,station=a1 temperature=24.3 1529933525520' newline ...
                'weather,city=barcelona,station=a1 temperature=-3.5 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function tags_from_struct(test)
            tags = struct('city', 'barcelona', 'station', 'a1');
            s = Series('weather') ...
                .time(test.Time) ...
                .tags(tags) ...
                .fields('temperature', test.Temperature);
            exp = [ ...
                'weather,city=barcelona,station=a1 temperature=24.3 1529933525520' newline ...
                'weather,city=barcelona,station=a1 temperature=-3.5 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function supports_multiple_tags_calls(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .tags('city', 'barcelona') ...
                .tags('station', 'a1') ...
                .fields('temperature', test.Temperature);
            exp = [ ...
                'weather,city=barcelona,station=a1 temperature=24.3 1529933525520' newline ...
                'weather,city=barcelona,station=a1 temperature=-3.5 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function fails_when_time_size_does_not_match_fields(test)
            s = Series('weather') ...
                .time(test.Time(1:end-1)) ...
                .fields('temperature', test.Temperature);
            test.verifyError(@() s.toLine(), 'toLine:sizeMismatch');
        end
        
        function fails_when_field_sizes_do_not_match(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .fields('temperature', test.Temperature) ...
                .fields('humidity', test.Humidity(1:end-1));
            test.verifyError(@() s.toLine(), 'toLine:sizeMismatch');
        end
        
        function every_property_is_used(test)
            s = Series('weather') ...
                .time(test.Time(1)) ...
                .tags('city', 'barcelona') ...
                .fields('temperature', 24.3);
            exp = 'weather,city=barcelona temperature=24.3 1529933525520';
            test.verifyEqual(s.toLine(), exp);
        end
        
        function every_property_is_used_with_multiple_samples(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .tags('city', 'barcelona') ...
                .fields('temperature', test.Temperature);
            exp = [ ...
                'weather,city=barcelona temperature=24.3 1529933525520' newline ...
                'weather,city=barcelona temperature=-3.5 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function skips_nonfinite_fields(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .fields('temperature', [NaN; -3.5]) ...
                .fields('humidity', [60.7; Inf]);
            exp = [ ...
                'weather humidity=60.7 1529933525520' newline ...
                'weather temperature=-3.5 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function skips_nonfinite_samples(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .fields('temperature', [24.3; Inf]) ...
                .fields('humidity', [-Inf; NaN]);
            exp = 'weather temperature=24.3 1529933525520';
            test.verifyEqual(s.toLine(), exp);
        end
        
        function returns_empty_when_all_values_are_nonfinite(test)
            s = Series('weather') ...
                .time(test.Time) ...
                .fields('temperature', [NaN; Inf]) ...
                .fields('humidity', [-Inf; NaN]);
            test.verifyEqual(s.toLine(), '');
        end
        
        function time_is_added_in_millis_by_default(test)
            millis = 1529933525520;
            time = datetime(millis / 1000, 'ConvertFrom', 'posixtime');
            s = Series('weather') ...
                .fields('temperature', 24.3) ...
                .time(time);
            exp = 'weather temperature=24.3 1529933525520';
            test.verifyEqual(s.toLine(), exp);
        end
        
        function time_supports_different_precisions(test)
            millis = 1529933525520;
            time = datetime(millis / 1000, 'ConvertFrom', 'posixtime');
            s = Series('weather') ...
                .fields('temperature', 24.3);
            precisions = struct( ...
                'ns', '1529933525520000000', ...
                'u', '1529933525520000', ...
                'ms', '1529933525520', ...
                's', '1529933526', ...
                'm', '25498892', ...
                'h', '424982');
            names = fieldnames(precisions);
            for i = 1:length(names)
                name = names{i};
                exp = [' ', precisions.(name)];
                line = s.time(time).toLine(name);
                test.verifyTrue(endsWith(line, exp));
            end
        end
        
        function imports_fields_from_table(test)
            props = {test.Temperature, test.WindDirection};
            names = {'temperature', 'wind_direction'};
            data = table(props{:}, 'VariableNames', names);
            s = Series('weather') ...
                .time(test.Time) ...
                .import(data);
            exp = [ ...
                'weather temperature=24.3,wind_direction="north" 1529933525520' newline ...
                'weather temperature=-3.5,wind_direction="west" 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function imports_time_and_fields_from_timetable(test)
            props = {test.Temperature, test.WindDirection};
            names = {'temperature', 'wind_direction'};
            data = timetable(test.Time, props{:}, 'VariableNames', names);
            s = Series('weather') ...
                .import(data);
            exp = [ ...
                'weather temperature=24.3,wind_direction="north" 1529933525520' newline ...
                'weather temperature=-3.5,wind_direction="west" 1529933581618'];
            test.verifyEqual(s.toLine(), exp);
        end
        
        function measurements_with_spaces_and_commas(test)
            s = Series('Hello, world!') ...
                .fields('value', 42);

            expected = 'Hello\,\ world! value=42';
            test.verifyEqual(s.toLine(), expected);
        end
        
        function tags_with_commas_spaces_and_equals(test)
            s = Series('Series_A') ...
                .tags('Annoying, tag = annoying', 'comma="evil", am i right?') ...
                .fields('value', 42);

            expected = 'Series_A,Annoying\,\ tag\ \=\ annoying=comma\="evil"\,\ am\ i\ right? value=42';
            test.verifyEqual(s.toLine(), expected);
        end
        
        function fields_with_commas_equals_spaces_quotes_and_slashes(test)
            s = Series('JSON') ...
                .fields('strange, json=string', '{"w": "\/\/"}');

            expected = 'JSON strange\,\ json\=string="{\"w\": \"\\/\\/\"}"';
            test.verifyEqual(s.toLine(), expected);
        end
    end
    
end
