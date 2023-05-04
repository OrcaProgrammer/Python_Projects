
%% Aircraft designer app
% Calculates the properties of electric planes

function Aircraft_designer


    %% Constants
    
    g = 9.81;
    ft_to_m = 0.3048;
    ft_mins_to_m_s = 0.00508;
    ft_mins_to_km_h = 0.018288;
    m_s_to_ft_mins = 196.8504;
    m_s_to_knots = 1.943844;
    knots_to_km_hr = 1.852;
    knots_to_m_s = 0.5144444;
    km_hr_to_m_s = 0.27777778;
    kW_to_W = 1000;
    N_to_kN = 1/1000;
    percent_to_dec = 1/100;
    
    rolling_coefficients = ...
        [0.03    0.3;
         0.05   0.15;
         0.02   0.06;
         0.07   0.2;
         0.08   0.2;
         0.2    0.4];

    
    %% Initiliase variables
    
    A = 0;
    C = 0;
    cruise_range = 0;
    cruise_altitude = 0;
    cruise_speed = 0;
    climb_rate = 0;
    loiter_time = 0;
    loiter_speed = 0;
    landing_surf_opt = 0;
    brakes_opt = 0;
    payload_mass = 0;
    engine_power = 0;
    max_speed = 0;
    bat_specific_energy = 0;
    sys_efficiency = 0;
    prop_efficiency = 0;
    LD_ratio = 0;
    wing_loading = 0;
    aspect_ratio = 0;
    max_Cl = 0;
    takeoff_Cl = 0;
    climb_Cl = 0;
    takeoff_Cdo = 0;
    climb_Cdo = 0;
    cruise_Cdo = 0;
    mass_guess = 0;
    calc_accuracy = 0;
    
    
    %% Setup app displays
    
    fig = uifigure;
    fig.Name = 'Aircraft Designer';
    fig.Position = [200 200 750 450];
    
    gl = uigridlayout(fig, [1,3]);
    gl.ColumnWidth = {400, 50, 200};
    
    user_inputs_tabgroup = uitabgroup(gl);
    
    empty_ratio_tab = uitab(user_inputs_tabgroup,"Title", "We/Wo Power Coefficents");
    empty_ratio_gl = uigridlayout(empty_ratio_tab, [3,2]);
    empty_ratio_gl.RowHeight = {30,30};
    empty_ratio_gl.ColumnWidth = {180,'1x'};
    
    A_label = uilabel(empty_ratio_gl, "Text", "A coefficient:", "WordWrap", "on");
    A_ed = uieditfield(empty_ratio_gl, 'numeric');
    C_label = uilabel(empty_ratio_gl, "Text", "C coefficient:", "WordWrap", "on");
    C_ed = uieditfield(empty_ratio_gl, 'numeric');

    mission_params_tab = uitab(user_inputs_tabgroup,"Title", "Mission Parameters");
    mission_params_gl = uigridlayout(mission_params_tab, [8,2]);
    mission_params_gl.RowHeight = {30,30,30,30,30,30,80,30};
    mission_params_gl.ColumnWidth = {180,'1x'};
    
    range_label = uilabel(mission_params_gl, "Text", "Cruise range:", "WordWrap", "on");
    range_ed = uieditfield(mission_params_gl, 'numeric', 'ValueDisplayFormat', '%.0f km');
    alt_label = uilabel(mission_params_gl, "Text", "Cruise altitude:", "WordWrap", "on");
    alt_ed = uieditfield(mission_params_gl, 'numeric', 'ValueDisplayFormat', '%.0f m');
    cruise_speed_label = uilabel(mission_params_gl, "Text", "Cruise speed:", "WordWrap", "on");
    cruise_speed_ed = uieditfield(mission_params_gl, 'numeric', 'ValueDisplayFormat', '%.0f knots');
    climb_rate_label = uilabel(mission_params_gl, "Text", "Target rate of climb:", "WordWrap", "on");
    climb_rate_ed = uieditfield(mission_params_gl, 'numeric', 'ValueDisplayFormat', '%.0f ft/min');
    loiter_time_label = uilabel(mission_params_gl, "Text", "Loiter time:", "WordWrap", "on");
    loiter_time_ed = uieditfield(mission_params_gl, 'numeric', 'ValueDisplayFormat', '%.2f hrs');
    loiter_speed_label = uilabel(mission_params_gl, "Text", "Loiter speed:", "WordWrap", "on");
    loiter_speed_ed = uieditfield(mission_params_gl, 'numeric', 'ValueDisplayFormat', '%.0f knots');
    
    rolling_coeff_bg_label = uilabel(mission_params_gl, "Text", "Landing Surface:", "WordWrap", "on");
    rolling_coeff_bg = uibuttongroup(mission_params_gl, "Title", "", "BorderType","none");
    rolling_coeff_dry_asp_option = uiradiobutton(rolling_coeff_bg, "Text", "Dry asphalt", "Value", true, ...
        "Position", [5, 52, 91, 22]);
    rolling_coeff_wet_asp_option = uiradiobutton(rolling_coeff_bg, "Text", "Wet asphalt", "Position", ...
        [105, 52, 91, 22]);
    rolling_coeff_icy_asp_option = uiradiobutton(rolling_coeff_bg, "Text", "Icy asphalt", "Position", ...
        [5, 26, 91, 22]);
    rolling_coeff_soft_turf_option = uiradiobutton(rolling_coeff_bg, "Text", "Soft turf", "Position", ...
        [105, 26, 91, 22]);
    rolling_coeff_wet_grass_option = uiradiobutton(rolling_coeff_bg, "Text", "Wet grass", "Position", ...
        [5, 0, 91, 22]);
    rolling_coeff_sand_option = uiradiobutton(rolling_coeff_bg, "Text", "Sand", "Position", ...
        [105, 0, 91, 22]);

    brakes_bg_label = uilabel(mission_params_gl, "Text", "Brakes:", "WordWrap", "on");
    brakes_bg = uibuttongroup(mission_params_gl, "Title", "", "BorderType","none");
    brakes_on_option = uiradiobutton(brakes_bg, "Text", "On", "Value", true, ...
        "Position", [5, 0, 91, 22]);
    brakes_off_option = uiradiobutton(brakes_bg, "Text", "Off", "Position", ...
        [105, 0, 91, 22]);

    aircraft_props_tab = uitab(user_inputs_tabgroup,"Title", "Aircraft Properties");
    aircraft_props_gl = uigridlayout(aircraft_props_tab, [6,2]);
    aircraft_props_gl.RowHeight = {30,30,30,30,30,30};
    aircraft_props_gl.ColumnWidth = {180,'1x'};
    
    payload_mass_label = uilabel(aircraft_props_gl, "Text", "Payload mass:", "WordWrap", "on");
    payload_mass_ed = uieditfield(aircraft_props_gl, 'numeric', 'ValueDisplayFormat', '%.0f kg');
    eng_power_label = uilabel(aircraft_props_gl, "Text", "Engine power:", "WordWrap", "on");
    eng_power_ed = uieditfield(aircraft_props_gl, 'numeric', 'ValueDisplayFormat', '%.0f kW');
    max_speed_label = uilabel(aircraft_props_gl, "Text", "Maximum speed:", "WordWrap", "on");
    max_speed_ed = uieditfield(aircraft_props_gl, 'numeric', 'ValueDisplayFormat', '%.0f knots');
    battery_energy_label = uilabel(aircraft_props_gl, "Text", "Battery specific energy:", "WordWrap", "on");
    battery_energy_ed = uieditfield(aircraft_props_gl, 'numeric', 'ValueDisplayFormat', '%.0f wh/kg');
    sys_efficiency_label = uilabel(aircraft_props_gl, "Text", "Battery to motor shaft efficiency",...
    "WordWrap", "on");
    sys_efficiency_ed = uieditfield(aircraft_props_gl, 'numeric', 'ValueDisplayFormat', '%.0f %%');
    prop_efficiency_label = uilabel(aircraft_props_gl, "Text", "Propeller efficiency:", "WordWrap", "on");
    prop_efficiency_ed = uieditfield(aircraft_props_gl, 'numeric', 'ValueDisplayFormat', '%.0f %%');
    
    wing_props_tab = uitab(user_inputs_tabgroup,"Title", "Wing Properties");
    wing_props_gl = uigridlayout(wing_props_tab, [9,2]);
    wing_props_gl.RowHeight = {30,30,30,30,30,30,30,30,30};
    wing_props_gl.ColumnWidth = {180,'1x'};
    
    LD_ratio_label = uilabel(wing_props_gl, "Text", "L/D ratio:", "WordWrap", "on");
    LD_ratio_ed = uieditfield(wing_props_gl, 'numeric');
    wing_load_label = uilabel(wing_props_gl, "Text", "Wing loading:", "WordWrap", "on");
    wing_load_ed = uieditfield(wing_props_gl, 'numeric', 'ValueDisplayFormat', '%.0f kg/m2');
    AR_label = uilabel(wing_props_gl, "Text", "Aspect ratio:", "WordWrap", "on");
    AR_ed = uieditfield(wing_props_gl, 'numeric');
    Cl_max_label = uilabel(wing_props_gl, "Text", "Cl (max):", "WordWrap", "on");
    Cl_max_ed = uieditfield(wing_props_gl, 'numeric');
    Cl_takeoff_label = uilabel(wing_props_gl, "Text", "Cl (take-off):", "WordWrap", "on");
    Cl_takeoff_ed = uieditfield(wing_props_gl, 'numeric');
    Cl_climb_label = uilabel(wing_props_gl, "Text", "Cl (climb):", "WordWrap", "on");
    Cl_climb_ed = uieditfield(wing_props_gl, 'numeric');
    Cdo_takeoff_label = uilabel(wing_props_gl, "Text", "Cdo (takeof):", "WordWrap", "on");
    Cdo_takeoff_ed = uieditfield(wing_props_gl, 'numeric');
    Cdo_climb_label = uilabel(wing_props_gl, "Text", "Cdo (climb):", "WordWrap", "on");
    Cdo_climb_ed = uieditfield(wing_props_gl, 'numeric');
    Cdo_cruise_label = uilabel(wing_props_gl, "Text", "Cdo (cruise):", "WordWrap", "on");
    Cdo_cruise_ed = uieditfield(wing_props_gl, 'numeric');
    
    calc_opts_tab = uitab(user_inputs_tabgroup,"Title", "Calculation Options");
    calc_opts_gl = uigridlayout(calc_opts_tab, [2,2]);
    calc_opts_gl.RowHeight = {30,30};
    calc_opts_gl.ColumnWidth = {180,'1x'};
    
    mass_guess_label = uilabel(calc_opts_gl, "Text", "Take-off mass guess:", "WordWrap", "on");
    mass_guess_ed = uieditfield(calc_opts_gl, 'numeric', 'ValueDisplayFormat', '%.0f kg');
    accuracy_label = uilabel(calc_opts_gl, "Text", "Accuracy of calculation:", "WordWrap", "on");
    accuracy_ed = uieditfield(calc_opts_gl, 'numeric');
    
    spacing_label = uilabel(gl, "Text", '');
    control_gl = uigridlayout(gl, [3,1]);
    control_gl.RowHeight = {52,52,52};
    control_gl.RowSpacing = 20;

    read_data = uibutton(control_gl, "Text", "Read Data File", ...
        "ButtonPushedFcn", @(btn, event) ReadDataFile());
    save_data = uibutton(control_gl, "Text", "Save Data File", ...
        "ButtonPushedFcn", @(btn, event) SaveDataFile());
    run_calc_btn = uibutton(control_gl, "Text", "Calculate", ...
        "ButtonPushedFcn", @(btn, event) CalculateAircraftProperties());


    function CalculateAircraftProperties
        

        % Read the data from inputs

        A = A_ed.Value;
        C = C_ed.Value;

        cruise_range = range_ed.Value;
        cruise_altitude = alt_ed.Value;
        cruise_speed = cruise_speed_ed.Value;
        climb_rate = climb_rate_ed.Value;
        loiter_time = loiter_time_ed.Value;
        loiter_speed = loiter_speed_ed.Value;

        switch rolling_coeff_bg.SelectedObject.Text
            case 'Dry asphalt'
                landing_surf_opt = 1;
            case 'Wet asphalt'
                landing_surf_opt = 2;
            case 'Icy asphalt'
                landing_surf_opt = 3;
            case 'Soft turf'
                landing_surf_opt = 4;
            case 'Wet grass'
                landing_surf_opt = 5;
            case 'Sand'
                landing_surf_opt = 6;
        end

        switch brakes_bg.SelectedObject.Text
            case 'On'
                brakes_opt = 2;
            case 'Off'
                brakes_opt = 1;
        end

        payload_mass = payload_mass_ed.Value;
        engine_power = eng_power_ed.Value;
        max_speed = max_speed_ed.Value;
        bat_specific_energy = battery_energy_ed.Value;
        sys_efficiency = sys_efficiency_ed.Value;
        prop_efficiency = prop_efficiency_ed.Value;

        LD_ratio = LD_ratio_ed.Value;
        wing_loading = wing_load_ed.Value;
        aspect_ratio = AR_ed.Value;
        max_Cl = Cl_max_ed.Value;
        takeoff_Cl = Cl_takeoff_ed.Value;
        climb_Cl = Cl_climb_ed.Value;
        takeoff_Cdo = Cdo_takeoff_ed.Value;
        climb_Cdo = Cdo_climb_ed.Value;
        cruise_Cdo = Cdo_cruise_ed.Value;

        mass_guess = mass_guess_ed.Value;
        calc_accuracy = accuracy_ed.Value;

        % Convert to right units
        
        climb_rate = ft_mins_to_m_s * climb_rate;
        cruise_speed = knots_to_km_hr * cruise_speed;
        loiter_speed = knots_to_km_hr * loiter_speed;
        max_speed = knots_to_m_s * max_speed;
        sys_efficiency = percent_to_dec * sys_efficiency;
        prop_efficiency = percent_to_dec * prop_efficiency;
        
        
        %% Calculate take-off weight
        
        if calc_accuracy == 0; calc_accuracy = 0.01; end
        aircraft_mass = 0;
        not_found_result = true;

        while not_found_result
        
            % Find empty mass ratio using statistical data
            empty_mass_ratio = A * (mass_guess) ^ C; 
        
            % BMF for take-off
            take_off_bmf = 0.03; % taken from statistical data
        
            % BMF for climb segment
            climb_bmf = (cruise_altitude * engine_power) / (3.6 * climb_rate * bat_specific_energy * ...
                sys_efficiency * mass_guess);
        
            % BMF for cruise segment
            cruise_bmf = (cruise_range * g) / (3.6 * bat_specific_energy * sys_efficiency * ...
                prop_efficiency * LD_ratio);


            % BMF for loiter segment
            loiter_bmf = (loiter_time * loiter_speed * g) / (3.6 * bat_specific_energy * ...
                sys_efficiency * prop_efficiency * LD_ratio);
        
            % BMF for landing segment
            landing_bmf = 0.005; % taken from statistical data
        
            % Overall BMF
            total_bmf = take_off_bmf + climb_bmf + cruise_bmf + loiter_bmf + landing_bmf;

            % Find the take_off_mass
            payload_weight = payload_mass * g;
            aircraft_weight = payload_weight / (1 - total_bmf - empty_mass_ratio);
            aircraft_mass = aircraft_weight / g;

            current_diff = abs(aircraft_mass) - mass_guess;
            if abs(current_diff) <= calc_accuracy; not_found_result = false; end
            mass_guess = mass_guess + current_diff/2;
        end
        
        
        %% Calculate Aircraft Properties
        
        % Wing geometry
        wing_area = aircraft_mass * g / wing_loading;
        wing_span = sqrt(aspect_ratio * wing_area);
        chord_avg = wing_span / aspect_ratio;
        
        % Max thrust
        max_thrust = (kW_to_W * engine_power * prop_efficiency/ max_speed);
        
        % Cruise performance
        [rho,~,~,~,~,~,~] = atmos(cruise_altitude);
        sweep = 0; %assume no sweep
        cruise_speed = km_hr_to_m_s * cruise_speed;
        e = 4.61 * (1 - 0.045 * aspect_ratio ^ 0.68) * (cos(deg2rad(sweep)) ^ 0.15) - 3.1;
        k = 1 / (pi * aspect_ratio * e); % induced drag factor
        cruise_Cl = (aircraft_mass * g) / (0.5 * rho * wing_area * cruise_speed ^ 2);
        cruise_Cd = cruise_Cdo + k * cruise_Cl ^ 2;
        cruise_drag = 0.5 * rho * wing_area * cruise_Cd * cruise_speed ^ 2;
        cruise_thrust = cruise_drag;
        
        % Rate of climb
        climb_Cd = climb_Cdo + k * climb_Cl ^ 2;%
        forward_climb_speed = sqrt(max_thrust / (1.5 * 1.225 * wing_area * climb_Cd));
        climb_rate_calc = (max_thrust * forward_climb_speed - (0.5 * 1.225 * wing_area * climb_Cd) ...
            * forward_climb_speed ^ 3) / (aircraft_mass * g); % climb rate in m/s
        
        % Stall speed
        stall_speed = sqrt((aircraft_mass * g) / (0.5 * 1.225 * wing_area * max_Cl));

        % Ground run
        lift_off_speed = 1.1 * stall_speed;
        mu = rolling_coefficients(landing_surf_opt, brakes_opt);
        takeoff_Cd = takeoff_Cdo + k * takeoff_Cl ^ 2;
        takeoff_thrust = (kW_to_W * engine_power) / lift_off_speed;

        C = (takeoff_thrust / aircraft_weight) - mu;
        D = ((-1.225 * wing_area * takeoff_Cl)/(2 * aircraft_weight)) * ...
            ((takeoff_Cd / takeoff_Cl) - mu);
        
        ground_run_distance = (log((D * lift_off_speed ^ 2) + C) - log(C)) / ...
            (2 * g * D);

        horz_climb_speed = 1.15 * stall_speed;
        obstacle_height = 50 * ft_to_m;
        time_to_clear = obstacle_height / climb_rate;
        climb_distance = horz_climb_speed * time_to_clear;

        take_off_distance = ground_run_distance + climb_distance;

        
        %% Display results

        results_fig = uifigure;
        results_fig.Name = 'Aircraft Properties';
        results_fig.Position = [500 250 700 380];

        results_gl = uigridlayout(results_fig, [5,1]);

        % Mass
        mass_panel = uipanel(results_gl, "Title", "Mass");
        mass_gl = uigridlayout(mass_panel, [1,2]);
        mass_gl.ColumnWidth = {'2x','1x'};

        mass_text_label = uilabel(mass_gl, "Text", "Aircraft mass:");
        aircraft_mass = round(aircraft_mass, 2);
        mass_label = uilabel(mass_gl, "Text", string(aircraft_mass) + ' kg');

        % Wing properties
        wing_calc_prop_panel = uipanel(results_gl, "Title", "Wing");
        wing_calc_prop_gl = uigridlayout(wing_calc_prop_panel, [1,6]);
        wing_calc_prop_gl.RowHeight = {26};
        wing_calc_prop_gl.ColumnWidth = {'2x','1x','2x','1x','2x','1x'};

        wing_area_text_label = uilabel(wing_calc_prop_gl, "Text", "Wing area:");
        wing_area = round(wing_area, 2);
        wing_area_label = uilabel(wing_calc_prop_gl, "Text", string(wing_area) + ' m2');
        wing_span_text_label = uilabel(wing_calc_prop_gl, "Text", "Wing span:");
        wing_span = round(wing_span, 2);
        wing_span_label = uilabel(wing_calc_prop_gl, "Text", string(wing_span) + ' m');
        avg_chord_text_label = uilabel(wing_calc_prop_gl, "Text", "Average chord:");
        chord_avg = round(chord_avg, 2);
        avg_chord_label = uilabel(wing_calc_prop_gl, "Text", string(chord_avg) + ' m');

        % Thrust
        thrust_panel = uipanel(results_gl, "Title", "Thrust");
        thrust_gl = uigridlayout(thrust_panel, [1,4]);
        thrust_gl.RowHeight = {26};
        thrust_gl.ColumnWidth = {'2x','1x','2x','1x'};
        
        max_thrust_text_label = uilabel(thrust_gl, "Text", "Max thrust:");
        max_thrust = N_to_kN * max_thrust;
        max_thrust = round(max_thrust, 2);
        max_thrust_label = uilabel(thrust_gl, "Text", string(max_thrust) + ' kN');
        cruise_thrust_text_label = uilabel(thrust_gl, "Text", "Cruise thrust:");
        cruise_thrust = N_to_kN * cruise_thrust;
        cruise_thrust = round(cruise_thrust, 2);
        cruise_thrust_label = uilabel(thrust_gl, "Text", string(cruise_thrust) + ' kN');

        % Mission performance
        mission_perf_panel = uipanel(results_gl, "Title", "Mission Performance");
        mission_perf_gl = uigridlayout(mission_perf_panel, [1,6]);
        mission_perf_gl.RowHeight = {26};
        mission_perf_gl.ColumnWidth = {'4x','2x','2x','2x','3x','2x'};
        
        climb_rate_calc_text_label = uilabel(mission_perf_gl, "Text", "Calculated climb rate:");
        climb_rate_calc = climb_rate_calc * m_s_to_ft_mins;
        climb_rate_calc = round(climb_rate_calc, 2);
        climb_rate_calc_label = uilabel(mission_perf_gl, "Text", string(climb_rate_calc) + ' ft/min');
        stall_speed_text_label = uilabel(mission_perf_gl, "Text", "Stall speed:");
        stall_speed = m_s_to_knots * stall_speed;
        stall_speed = round(stall_speed, 2);
        stall_speed_label = uilabel(mission_perf_gl, "Text", string(stall_speed) + ' knots');
        take_off_dist_text_label = uilabel(mission_perf_gl, "Text", "Take off distance:");
        take_off_distance = round(take_off_distance, 2);
        take_off_dist_label = uilabel(mission_perf_gl, "Text", string(take_off_distance) + ' m');


    end


    %% Read sizing data file
    function ReadDataFile
        
        f = figure('Renderer', 'painters', 'Position', [-100 -100 0 0]);
        [file,path] = uigetfile('*.dat');
        delete(f);

        if isequal(file,0)
           disp('User selected Cancel');
        else
           data = readmatrix(fullfile(path, file));

           A_ed.Value = data(1);
           C_ed.Value = data(2);

           range_ed.Value = data(3);
           alt_ed.Value = data(4);
           cruise_speed_ed.Value = data(5);
           climb_rate_ed.Value = data(6);
           loiter_time_ed.Value = data(7);
           loiter_speed_ed.Value = data(8);

           switch data(9)
               case 1
                   rolling_coeff_dry_asp_option.Value = true;
               case 2
                   rolling_coeff_wet_asp_option.Value = true;
               case 3
                   rolling_coeff_icy_asp_option.Value = true;
               case 4
                   rolling_coeff_soft_turf_option.Value = true;
               case 5
                   rolling_coeff_wet_grass_option.Value = true;
               case 6
                   rolling_coeff_sand_option.Value = true;
           end
    
           switch data(10)
               case 2
                   brakes_on_option.Value = true;
               case 1
                   brakes_off_option.Value = true;
           end

           payload_mass_ed.Value = data(11);
           eng_power_ed.Value = data(12);
           max_speed_ed.Value = data(13);
           battery_energy_ed.Value = data(14);
           sys_efficiency_ed.Value = data(15);
           prop_efficiency_ed.Value = data(16);
           LD_ratio_ed.Value = data(17);
           wing_load_ed.Value = data(18);
           AR_ed.Value = data(19);
           Cl_max_ed.Value = data(20);
           Cl_takeoff_ed.Value = data(21);
           Cl_climb_ed.Value = data(22);
           Cdo_takeoff_ed.Value = data(23);
           Cdo_climb_ed.Value = data(24);
           Cdo_cruise_ed.Value = data(25);
           mass_guess_ed.Value = data(26);
           accuracy_ed.Value = data(27);


        end

    end


    %% Save sizing data file
    function SaveDataFile

        f = figure('Renderer', 'painters', 'Position', [-100 -100 0 0]);
        [file,path] = uiputfile('sizing_data.dat');
        delete(f);

        if isequal(file,0) || isequal(path,0)
            disp('User clicked Cancel.');
        else
            
            % Read the data from inputs

            A = A_ed.Value;
            C = C_ed.Value;

            cruise_range = range_ed.Value;
            cruise_altitude = alt_ed.Value;
            cruise_speed = cruise_speed_ed.Value;
            climb_rate = climb_rate_ed.Value;
            loiter_time = loiter_time_ed.Value;
            loiter_speed = loiter_speed_ed.Value;

            switch rolling_coeff_bg.SelectedObject.Text
                case 'Dry asphalt'
                    landing_surf_opt = 1;
                case 'Wet asphalt'
                    landing_surf_opt = 2;
                case 'Icy asphalt'
                    landing_surf_opt = 3;
                case 'Soft turf'
                    landing_surf_opt = 4;
                case 'Wet grass'
                    landing_surf_opt = 5;
                case 'Sand'
                    landing_surf_opt = 6;
            end
            
            switch brakes_bg.SelectedObject.Text
                case 'On'
                    brakes_opt = 2;
                case 'Off'
                    brakes_opt = 1;
            end

            payload_mass = payload_mass_ed.Value;
            engine_power = eng_power_ed.Value;
            max_speed = max_speed_ed.Value;
            bat_specific_energy = battery_energy_ed.Value;
            sys_efficiency = sys_efficiency_ed.Value;
            prop_efficiency = prop_efficiency_ed.Value;

            LD_ratio = LD_ratio_ed.Value;
            wing_loading = wing_load_ed.Value;
            aspect_ratio = AR_ed.Value;
            max_Cl = Cl_max_ed.Value;
            takeoff_Cl = Cl_takeoff_ed.Value;
            climb_Cl = Cl_climb_ed.Value;
            takeoff_Cdo = Cdo_takeoff_ed.Value;
            climb_Cdo = Cdo_climb_ed.Value;
            cruise_Cdo = Cdo_cruise_ed.Value;

            mass_guess = mass_guess_ed.Value;
            calc_accuracy = accuracy_ed.Value;

            data = [A, C, cruise_range, cruise_altitude, cruise_speed, climb_rate, ...
                loiter_time, loiter_speed, landing_surf_opt, brakes_opt, payload_mass, engine_power,...
                max_speed, bat_specific_energy, sys_efficiency, prop_efficiency, LD_ratio, wing_loading,...
                aspect_ratio, max_Cl, takeoff_Cl, climb_Cl, takeoff_Cdo, climb_Cdo, cruise_Cdo,...
                mass_guess, calc_accuracy];

            writematrix(data, fullfile(path, file));

        end
    end
end
