function Laser_GUIcs4_17
    % 激光轴对中仿真系统
    % 当前版本：
    % 1) 基于当前基准代码继续修改
    % 2) 增加 S / M 两侧安装偏差与横滚角
    % 3) 保留 S-PSD / M-PSD 局部二维输出
    % 4) S / M 两侧 X-theta 分开画
    % 5) S轴延伸到原点
    % 6) S机盒夹具杆子同时连到 PSD 和 LD
    % 7) 补回 LD 发出的虚线光路示意

    % --- 1. 创建主界面窗口 ---
    fig = figure('Name', '激光轴对中仿真系统（双LD-双PSD前向模型）', ...
                 'NumberTitle', 'off', ...
                 'Position', [20, 20, 1580, 940], ...
                 'Color', 'w', ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'figure');

    %% --- 2. 左侧布局 ---
    Panel_width = 0.20;
    handles = struct();

    % -----------------------------
    % 区域 1: 不对中量设定
    % -----------------------------
    pnl_mis = uipanel('Parent', fig, 'Title', '1. 不对中量设定 (真值)', ...
                      'FontSize', 11, 'FontWeight', 'bold', ...
                      'Position', [0.01, 0.73, Panel_width, 0.24], ...
                      'BackgroundColor', [0.96 0.98 1.0]);

    H_edit = 0.12;
    H_lbl  = 0.09;
    Gap    = 0.015;
    Y_pos  = 0.84;

    uicontrol(pnl_mis, 'Style', 'text', 'String', '水平偏心 h (mm):', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos, 0.90, H_lbl], ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.96 0.98 1.0]);
    handles.edit_h = uicontrol(pnl_mis, 'Style', 'edit', 'String', '4.5', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos-H_lbl, 0.90, H_edit]);

    Y_pos = Y_pos - H_edit - H_lbl - Gap;
    uicontrol(pnl_mis, 'Style', 'text', 'String', '垂直偏心 k (mm):', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos, 0.90, H_lbl], ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.96 0.98 1.0]);
    handles.edit_k = uicontrol(pnl_mis, 'Style', 'edit', 'String', '-4.8', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos-H_lbl, 0.90, H_edit]);

    Y_pos = Y_pos - H_edit - H_lbl - Gap;
    uicontrol(pnl_mis, 'Style', 'text', 'String', '水平偏角 Alpha (mm/100mm):', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos, 0.90, H_lbl], ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.96 0.98 1.0]);
    handles.edit_alpha = uicontrol(pnl_mis, 'Style', 'edit', 'String', '5.0', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos-H_lbl, 0.90, H_edit]);

    Y_pos = Y_pos - H_edit - H_lbl - Gap;
    uicontrol(pnl_mis, 'Style', 'text', 'String', '垂直偏角 Beta (mm/100mm):', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos, 0.90, H_lbl], ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.96 0.98 1.0]);
    handles.edit_beta = uicontrol(pnl_mis, 'Style', 'edit', 'String', '-5.5', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos-H_lbl, 0.90, H_edit]);

    % -----------------------------
    % 区域 2: 机器几何参数
    % -----------------------------
    pnl_geom = uipanel('Parent', fig, 'Title', '2. 机器几何参数', ...
                       'FontSize', 11, 'FontWeight', 'bold', ...
                       'Position', [0.01, 0.58, Panel_width, 0.13], ...
                       'BackgroundColor', [0.95 1.0 0.95]);

    Y_pos = 0.68;
    uicontrol(pnl_geom, 'Style', 'text', 'String', 'S机、M机距离 (mm):', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos, 0.90, 0.20], ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.95 1.0 0.95]);
    handles.edit_Mlen = uicontrol(pnl_geom, 'Style', 'edit', 'String', '200', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos-0.20, 0.90, 0.23]);

    Y_pos = Y_pos - 0.45;
    uicontrol(pnl_geom, 'Style', 'text', 'String', '安装半径 Ld (mm):', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos, 0.90, 0.20], ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.95 1.0 0.95]);
    handles.edit_Ld = uicontrol(pnl_geom, 'Style', 'edit', 'String', '30', ...
        'Units', 'normalized', 'Position', [0.05, Y_pos-0.20, 0.90, 0.23]);

    % -----------------------------
    % 区域 3: M机盒安装偏差
    % -----------------------------
    pnl_err_M = uipanel('Parent', fig, 'Title', '3. M机盒安装偏差', ...
                        'FontSize', 11, 'FontWeight', 'bold', ...
                        'Position', [0.01, 0.29, Panel_width, 0.27], ...
                        'BackgroundColor', [1.0 0.96 0.96], ...
                        'ForegroundColor', [0.6 0 0]);

    Y_pos = 0.88;
    H_e   = 0.095;
    H_l   = 0.075;
    Step  = 0.155;

    handles.edit_mnt_h_M = add_label_edit(pnl_err_M, '高度误差 (mm):',   Y_pos, H_l, H_e, [1 0.96 0.96], '0');      Y_pos = Y_pos - Step;
    handles.edit_mnt_r_M = add_label_edit(pnl_err_M, '夹具横滚 (°):',   Y_pos, H_l, H_e, [1 0.96 0.96], '0');      Y_pos = Y_pos - Step;
    handles.edit_mnt_p_M = add_label_edit(pnl_err_M, '夹具俯仰 (°):',   Y_pos, H_l, H_e, [1 0.96 0.96], '0');      Y_pos = Y_pos - Step;
    handles.edit_mnt_y_M = add_label_edit(pnl_err_M, '夹具偏航 (°):',   Y_pos, H_l, H_e, [1 0.96 0.96], '0');      Y_pos = Y_pos - Step;
    handles.edit_int_p_M = add_label_edit(pnl_err_M, 'LD内部俯仰 (°):', Y_pos, H_l, H_e, [1 0.96 0.96], '0', 'b'); Y_pos = Y_pos - Step;
    handles.edit_int_y_M = add_label_edit(pnl_err_M, 'LD内部偏航 (°):', Y_pos, H_l, H_e, [1 0.96 0.96], '0', 'b');

    % -----------------------------
    % 区域 4: S机盒安装偏差
    % -----------------------------
    pnl_err_S = uipanel('Parent', fig, 'Title', '4. S机盒安装偏差', ...
                        'FontSize', 11, 'FontWeight', 'bold', ...
                        'Position', [0.01, 0.03, Panel_width, 0.24], ...
                        'BackgroundColor', [0.96 0.98 1.0], ...
                        'ForegroundColor', [0 0.2 0.6]);

    Y_pos = 0.87;
    H_e   = 0.09;
    H_l   = 0.07;
    Step  = 0.15;

    handles.edit_mnt_h_S = add_label_edit(pnl_err_S, '高度误差 (mm):',   Y_pos, H_l, H_e, [0.96 0.98 1.0], '0');      Y_pos = Y_pos - Step;
    handles.edit_mnt_r_S = add_label_edit(pnl_err_S, '夹具横滚 (°):',   Y_pos, H_l, H_e, [0.96 0.98 1.0], '0');      Y_pos = Y_pos - Step;
    handles.edit_mnt_p_S = add_label_edit(pnl_err_S, '夹具俯仰 (°):',   Y_pos, H_l, H_e, [0.96 0.98 1.0], '0');      Y_pos = Y_pos - Step;
    handles.edit_mnt_y_S = add_label_edit(pnl_err_S, '夹具偏航 (°):',   Y_pos, H_l, H_e, [0.96 0.98 1.0], '0');      Y_pos = Y_pos - Step;
    handles.edit_int_p_S = add_label_edit(pnl_err_S, 'LD内部俯仰 (°):', Y_pos, H_l, H_e, [0.96 0.98 1.0], '0', 'b'); Y_pos = Y_pos - Step;
    handles.edit_int_y_S = add_label_edit(pnl_err_S, 'LD内部偏航 (°):', Y_pos, H_l, H_e, [0.96 0.98 1.0], '0', 'b');

    % --- 运行按钮 ---
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '运行仿真', ...
              'Units', 'normalized', 'Position', [0.01, 0.001, Panel_width, 0.025], ...
              'FontSize', 11, 'FontWeight', 'bold', ...
              'BackgroundColor', [0.2 0.4 0.8], 'ForegroundColor', 'w', ...
              'Callback', {@run_simulation, fig});

    %% --- 3. 右侧绘图区域 ---
    handles.ax1 = axes('Parent', fig, 'Position', [0.23, 0.14, 0.34, 0.74]); % 3D
    handles.ax2 = axes('Parent', fig, 'Position', [0.60, 0.62, 0.17, 0.22]); % S 全局YZ
    handles.ax3 = axes('Parent', fig, 'Position', [0.80, 0.62, 0.17, 0.22]); % M 全局YZ
    handles.ax4 = axes('Parent', fig, 'Position', [0.60, 0.34, 0.17, 0.22]); % S 局部uv
    handles.ax5 = axes('Parent', fig, 'Position', [0.80, 0.34, 0.17, 0.22]); % M 局部uv
    handles.ax6 = axes('Parent', fig, 'Position', [0.60, 0.08, 0.17, 0.16]); % S侧 X-theta
    handles.ax7 = axes('Parent', fig, 'Position', [0.80, 0.08, 0.17, 0.16]); % M侧 X-theta

    guidata(fig, handles);
    run_simulation([], [], fig);
end

function run_simulation(~, ~, fig_handle)
    handles = guidata(fig_handle);

    % -----------------------------
    % 获取输入参数
    % -----------------------------
    h = str2double(get(handles.edit_h, 'String'));
    k = str2double(get(handles.edit_k, 'String'));
    alpha_u = str2double(get(handles.edit_alpha, 'String'));
    beta_u  = str2double(get(handles.edit_beta, 'String'));

    alpha_deg = atand(alpha_u / 100);
    beta_deg  = atand(beta_u / 100);

    M_len_val = str2double(get(handles.edit_Mlen, 'String'));
    Ld_base   = str2double(get(handles.edit_Ld, 'String'));

    % M side
    M_mnt_h = str2double(get(handles.edit_mnt_h_M, 'String'));
    M_mnt_r = str2double(get(handles.edit_mnt_r_M, 'String'));
    M_mnt_p = str2double(get(handles.edit_mnt_p_M, 'String'));
    M_mnt_y = str2double(get(handles.edit_mnt_y_M, 'String'));
    M_int_p = str2double(get(handles.edit_int_p_M, 'String'));
    M_int_y = str2double(get(handles.edit_int_y_M, 'String'));

    % S side
    S_mnt_h = str2double(get(handles.edit_mnt_h_S, 'String'));
    S_mnt_r = str2double(get(handles.edit_mnt_r_S, 'String'));
    S_mnt_p = str2double(get(handles.edit_mnt_p_S, 'String'));
    S_mnt_y = str2double(get(handles.edit_mnt_y_S, 'String'));
    S_int_p = str2double(get(handles.edit_int_p_S, 'String'));
    S_int_y = str2double(get(handles.edit_int_y_S, 'String'));

    % -----------------------------
    % 全局几何
    % -----------------------------
    M_start = [0; h; k];

    M_length  = M_len_val * 2;
    alpha_rad = deg2rad(alpha_deg);
    beta_rad  = deg2rad(beta_deg);

    v = [1; tan(alpha_rad); tan(beta_rad)];
    U_axis = v / norm(v);

    V_axis     = U_axis * M_length;
    M_end      = M_start + V_axis;
    Center_Pos = M_start + V_axis * 0.5;

    PSD_X_S = -M_len_val;
    S_start = [PSD_X_S; 0; 0];
    U_S_axis = [1; 0; 0];

    % -----------------------------
    % 建立理想截面基底
    % -----------------------------
    ref_Z = [0; 0; 1];
    vec_h = cross(U_axis, ref_Z);
    if norm(vec_h) < 1e-6
        vec_h = [0; 1; 0];
    end
    n1_M = cross(vec_h, U_axis); n1_M = n1_M / norm(n1_M);
    n2_M = cross(U_axis, n1_M);  n2_M = n2_M / norm(n2_M);

    % 保持你当前代码风格
    n1_S = [0; 0; 1];
    n2_S = [0; -1; 0];

    % -----------------------------
    % 结构尺寸
    % -----------------------------
    R_M_LD  = Ld_base;
    R_M_PSD = Ld_base + 40;
    R_S_PSD = Ld_base;
    R_S_LD  = Ld_base + 40;

    R_M_LD_eff  = R_M_LD  + M_mnt_h;
    R_M_PSD_eff = R_M_PSD + M_mnt_h;
    R_S_LD_eff  = R_S_LD  + S_mnt_h;
    R_S_PSD_eff = R_S_PSD + S_mnt_h;

    % -----------------------------
    % 存储
    % -----------------------------
    num_points = 360;
    th_list = linspace(0, 2*pi, num_points);
    th_deg  = rad2deg(th_list);

    pts_M_to_S_id  = nan(3, num_points);
    pts_M_to_S_err = nan(3, num_points);
    pts_S_to_M_id  = nan(3, num_points);
    pts_S_to_M_err = nan(3, num_points);

    uv_S_id  = nan(2, num_points);
    uv_S_err = nan(2, num_points);
    uv_M_id  = nan(2, num_points);
    uv_M_err = nan(2, num_points);

    % -----------------------------
    % 角度转弧度
    % -----------------------------
    M_roll  = deg2rad(M_mnt_r);
    M_pitch = deg2rad(M_mnt_p);
    M_yaw   = deg2rad(M_mnt_y);
    M_ip    = deg2rad(M_int_p);
    M_iy    = deg2rad(M_int_y);

    S_roll  = deg2rad(S_mnt_r);
    S_pitch = deg2rad(S_mnt_p);
    S_yaw   = deg2rad(S_mnt_y);
    S_ip    = deg2rad(S_int_p);
    S_iy    = deg2rad(S_int_y);

    % -----------------------------
    % 主循环
    % -----------------------------
    for i = 1:num_points
        th = th_list(i);

        % 理想径向 / 切向
        n_r_M = cos(th) * n1_M + sin(th) * n2_M;
        n_t_M = cross(U_axis, n_r_M);
        n_t_M = n_t_M / norm(n_t_M);

        n_r_S = cos(th) * n1_S + sin(th) * n2_S;
        n_t_S = cross(U_S_axis, n_r_S);
        n_t_S = n_t_S / norm(n_t_S);

        % M机盒姿态：roll -> pitch -> yaw
        [e_r_M, e_t_M, N_M_box] = build_box_frame(U_axis, n_r_M, n_t_M, M_roll, M_pitch, M_yaw);

        % M侧安装点
        P_LD_M_id   = Center_Pos + R_M_LD  * n_r_M;
        P_PSD_M_id  = Center_Pos + R_M_PSD * n_r_M;
        P_LD_M_err  = Center_Pos + R_M_LD_eff  * e_r_M;
        P_PSD_M_err = Center_Pos + R_M_PSD_eff * e_r_M;

        % M-LD 实际出射方向
        V_M_tmp = rodrigues_rot(N_M_box, e_t_M, M_ip);
        V_M_err = rodrigues_rot(V_M_tmp, e_r_M, M_iy);
        V_M_err = V_M_err / norm(V_M_err);

        % S机盒姿态：roll -> pitch -> yaw
        [e_r_S, e_t_S, N_S_box] = build_box_frame(U_S_axis, n_r_S, n_t_S, S_roll, S_pitch, S_yaw);

        % S侧安装点
        P_S_PSD_id   = S_start + R_S_PSD * n_r_S;
        P_S_LD_id    = S_start + R_S_LD  * n_r_S;
        P_S_PSD_err  = S_start + R_S_PSD_eff * e_r_S;
        P_S_LD_err   = S_start + R_S_LD_eff  * e_r_S;

        % S-LD 实际出射方向
        V_S_tmp = rodrigues_rot(N_S_box, e_t_S, S_ip);
        V_S_err = rodrigues_rot(V_S_tmp, e_r_S, S_iy);
        V_S_err = V_S_err / norm(V_S_err);

        % 光束1：M-LD -> S-PSD
        [P_hit_S_id, ok1] = line_plane_intersection(P_LD_M_id, U_axis, P_S_PSD_id, U_S_axis);
        if ok1
            pts_M_to_S_id(:, i) = P_hit_S_id;
        end

        [P_hit_S_err, ok2] = line_plane_intersection(P_LD_M_err, V_M_err, P_S_PSD_err, N_S_box);
        if ok2
            pts_M_to_S_err(:, i) = P_hit_S_err;
        end

        % 光束2：S-LD -> M-PSD
        [P_hit_M_id, ok3] = line_plane_intersection(P_S_LD_id, U_S_axis, P_PSD_M_id, U_axis);
        if ok3
            pts_S_to_M_id(:, i) = P_hit_M_id;
        end

        [P_hit_M_err, ok4] = line_plane_intersection(P_S_LD_err, V_S_err, P_PSD_M_err, N_M_box);
        if ok4
            pts_S_to_M_err(:, i) = P_hit_M_err;
        end

        % S-PSD 局部二维输出
        if ok1
            vec_sid = P_hit_S_id - P_S_PSD_id;
            uv_S_id(:, i) = [dot(vec_sid, n_r_S); dot(vec_sid, n_t_S)];
        end
        if ok2
            vec_serr = P_hit_S_err - P_S_PSD_err;
            uv_S_err(:, i) = [dot(vec_serr, e_r_S); dot(vec_serr, e_t_S)];
        end

        % M-PSD 局部二维输出
        if ok3
            vec_mid = P_hit_M_id - P_PSD_M_id;
            uv_M_id(:, i) = [dot(vec_mid, n_r_M); dot(vec_mid, n_t_M)];
        end
        if ok4
            vec_merr = P_hit_M_err - P_PSD_M_err;
            uv_M_err(:, i) = [dot(vec_merr, e_r_M); dot(vec_merr, e_t_M)];
        end
    end

    % ===============================
    % 绘图逻辑
    % ===============================

    % --- ax1: 3D 三维图 ---
    ax1 = handles.ax1;
    cla(ax1);
    axes(ax1);
    hold on; grid on; axis equal; view(3);
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title('三维空间双LD-双PSD前向模型');

    limit = max(abs([M_end(:); PSD_X_S; R_S_LD_eff; R_M_PSD_eff])) * 1.5 + 20;
    xlim([-limit, limit]);
    ylim([-limit/2, limit/2]);
    zlim([-limit/2, limit/2]);

    quiver3(0,0,0, limit/3,0,0, 'k', 'LineWidth', 1); text(limit/3,0,0, 'X');
    quiver3(0,0,0, 0,limit/3,0, 'k', 'LineWidth', 1); text(0,limit/3,0, 'Y');
    quiver3(0,0,0, 0,0,limit/3, 'k', 'LineWidth', 1); text(0,0,limit/3, 'Z');

    fill3([PSD_X_S, PSD_X_S, PSD_X_S, PSD_X_S], ...
          [-limit, limit, limit, -limit], ...
          [-limit, -limit, limit, limit], ...
          [0.9 0.9 0.9], 'FaceAlpha', 0.35, 'EdgeColor', 'none');

    % 轴线
    plot3([M_start(1), M_end(1)], [M_start(2), M_end(2)], [M_start(3), M_end(3)], ...
          'b-', 'LineWidth', 2);
    text(M_end(1), M_end(2), M_end(3), ' M轴 ');

    % S轴延伸到原点
    S_axis_end = [0, 0, 0];
    plot3([S_start(1), S_axis_end(1)], [0, 0], [0, 0], ...
          'b-', 'LineWidth', 2);
    text(S_start(1), 0, 0, ' S轴 ');

    % 轨迹
    plot3(pts_M_to_S_err(1,:), pts_M_to_S_err(2,:), pts_M_to_S_err(3,:), ...
          'g-', 'LineWidth', 2, 'DisplayName', 'M-LD -> S-PSD');
    plot3(pts_S_to_M_err(1,:), pts_S_to_M_err(2,:), pts_S_to_M_err(3,:), ...
          'm-', 'LineWidth', 2, 'DisplayName', 'S-LD -> M-PSD');

    % 补回 LD 发出的虚线光路示意
    step_draw = 15;
    for i = 1:step_draw:num_points
        th = th_list(i);

        n_r_M = cos(th) * n1_M + sin(th) * n2_M;
        n_t_M = cross(U_axis, n_r_M);
        n_t_M = n_t_M / norm(n_t_M);

        n_r_S = cos(th) * n1_S + sin(th) * n2_S;
        n_t_S = cross(U_S_axis, n_r_S);
        n_t_S = n_t_S / norm(n_t_S);

        [e_r_M_i, ~, ~] = build_box_frame(U_axis, n_r_M, n_t_M, M_roll, M_pitch, M_yaw);
        [e_r_S_i, ~, ~] = build_box_frame(U_S_axis, n_r_S, n_t_S, S_roll, S_pitch, S_yaw);

        P_LD_M_i = Center_Pos + R_M_LD_eff * e_r_M_i;
        P_LD_S_i = S_start   + R_S_LD_eff * e_r_S_i;

        if all(~isnan(pts_M_to_S_err(:, i)))
            plot3([P_LD_M_i(1), pts_M_to_S_err(1,i)], ...
                  [P_LD_M_i(2), pts_M_to_S_err(2,i)], ...
                  [P_LD_M_i(3), pts_M_to_S_err(3,i)], ...
                  'g:', 'LineWidth', 0.7);
        end

        if all(~isnan(pts_S_to_M_err(:, i)))
            plot3([P_LD_S_i(1), pts_S_to_M_err(1,i)], ...
                  [P_LD_S_i(2), pts_S_to_M_err(2,i)], ...
                  [P_LD_S_i(3), pts_S_to_M_err(3,i)], ...
                  'm:', 'LineWidth', 0.7);
        end
    end

    % 当前时刻结构示意：theta = 0
    th0 = th_list(1);
    n_r_M0 = cos(th0) * n1_M + sin(th0) * n2_M;
    n_t_M0 = cross(U_axis, n_r_M0);
    n_t_M0 = n_t_M0 / norm(n_t_M0);
    [e_r_M0, ~, ~] = build_box_frame(U_axis, n_r_M0, n_t_M0, M_roll, M_pitch, M_yaw);

    n_r_S0 = cos(th0) * n1_S + sin(th0) * n2_S;
    n_t_S0 = cross(U_S_axis, n_r_S0);
    n_t_S0 = n_t_S0 / norm(n_t_S0);
    [e_r_S0, ~, ~] = build_box_frame(U_S_axis, n_r_S0, n_t_S0, S_roll, S_pitch, S_yaw);

    P_M_LD_0  = Center_Pos + R_M_LD_eff  * e_r_M0;
    P_M_PSD_0 = Center_Pos + R_M_PSD_eff * e_r_M0;
    plot3([Center_Pos(1), P_M_PSD_0(1)], ...
          [Center_Pos(2), P_M_PSD_0(2)], ...
          [Center_Pos(3), P_M_PSD_0(3)], ...
          'k-', 'LineWidth', 2);
    plot3(P_M_LD_0(1), P_M_LD_0(2), P_M_LD_0(3), ...
          'yo', 'MarkerSize', 8, 'MarkerFaceColor', 'y');
    plot3(P_M_PSD_0(1), P_M_PSD_0(2), P_M_PSD_0(3), ...
          'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    text(P_M_LD_0(1), P_M_LD_0(2), P_M_LD_0(3)-5, 'M-LD', ...
         'FontSize', 8, 'FontWeight', 'bold');
    text(P_M_PSD_0(1), P_M_PSD_0(2), P_M_PSD_0(3)+5, 'M-PSD', ...
         'FontSize', 8, 'FontWeight', 'bold');

    P_S_PSD_0 = S_start + R_S_PSD_eff * e_r_S0;
    P_S_LD_0  = S_start + R_S_LD_eff  * e_r_S0;

    % S机盒杆子分别连到 PSD 和 LD
    plot3([S_start(1), P_S_PSD_0(1)], ...
          [S_start(2), P_S_PSD_0(2)], ...
          [S_start(3), P_S_PSD_0(3)], ...
          'k-', 'LineWidth', 2);

    plot3([S_start(1), P_S_LD_0(1)], ...
          [S_start(2), P_S_LD_0(2)], ...
          [S_start(3), P_S_LD_0(3)], ...
          'k-', 'LineWidth', 2);

    plot3([P_S_PSD_0(1), P_S_LD_0(1)], ...
          [P_S_PSD_0(2), P_S_LD_0(2)], ...
          [P_S_PSD_0(3), P_S_LD_0(3)], ...
          'k--', 'LineWidth', 1);

    plot3(P_S_PSD_0(1), P_S_PSD_0(2), P_S_PSD_0(3), ...
          'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
    plot3(P_S_LD_0(1),  P_S_LD_0(2),  P_S_LD_0(3), ...
          'yo', 'MarkerSize', 8, 'MarkerFaceColor', 'y');
    text(P_S_PSD_0(1), P_S_PSD_0(2), P_S_PSD_0(3)-5, 'S-PSD', ...
         'FontSize', 8, 'FontWeight', 'bold');
    text(P_S_LD_0(1),  P_S_LD_0(2),  P_S_LD_0(3)+5, 'S-LD', ...
         'FontSize', 8, 'FontWeight', 'bold');

    % --- ax2: S机全局投影 ---
    ax2 = handles.ax2;
    cla(ax2);
    axes(ax2);
    hold on; grid on; axis equal;
    title('S机接收面投影');
    xlabel('Y (mm)'); ylabel('Z (mm)');
    plot(pts_M_to_S_id(2,:),  pts_M_to_S_id(3,:),  'r--', 'DisplayName', '理想轨迹');
    plot(pts_M_to_S_err(2,:), pts_M_to_S_err(3,:), 'g-',  'LineWidth', 1.5, 'DisplayName', '实际轨迹');
    plot(0, 0, 'k+', 'MarkerSize', 10, 'HandleVisibility', 'off');
    legend('show', 'Location', 'best');
    set_axis_by_data(ax2, [pts_M_to_S_id(2,:), pts_M_to_S_err(2,:)], ...
                          [pts_M_to_S_id(3,:), pts_M_to_S_err(3,:)], 5);

    % --- ax3: M机全局投影 ---
    ax3 = handles.ax3;
    cla(ax3);
    axes(ax3);
    hold on; grid on; axis equal;
    title('M机接收面投影（全局 Y-Z）');
    xlabel('Y (mm)'); ylabel('Z (mm)');
    plot(pts_S_to_M_id(2,:),  pts_S_to_M_id(3,:),  'r--', 'LineWidth', 1.0, 'DisplayName', '理想轨迹');
    plot(pts_S_to_M_err(2,:), pts_S_to_M_err(3,:), 'm-',  'LineWidth', 1.5, 'DisplayName', '实际轨迹');
    plot(0, 0, 'k+', 'MarkerSize', 10, 'HandleVisibility', 'off');
    legend('show', 'Location', 'best');
    set_axis_by_data(ax3, [pts_S_to_M_id(2,:), pts_S_to_M_err(2,:)], ...
                          [pts_S_to_M_id(3,:), pts_S_to_M_err(3,:)], 5);

    % --- ax4: S-PSD 局部二维输出 ---
    ax4 = handles.ax4;
    cla(ax4);
    axes(ax4);
    hold on; grid on; axis equal;
    title('S-PSD 局部二维输出');
    xlabel('u_S (mm)');
    ylabel('v_S (mm)');
    plot_with_point_support(ax4, uv_S_id(1,:),  uv_S_id(2,:),  'r--', '理想轨迹');
    plot_with_point_support(ax4, uv_S_err(1,:), uv_S_err(2,:), 'g-',  '实际轨迹');
    plot(0, 0, 'k+', 'MarkerSize', 10, 'HandleVisibility', 'off');
    legend('show', 'Location', 'best');
    set_axis_by_data(ax4, [uv_S_id(1,:), uv_S_err(1,:)], ...
                          [uv_S_id(2,:), uv_S_err(2,:)], 2);

    % --- ax5: M-PSD 局部二维输出 ---
    ax5 = handles.ax5;
    cla(ax5);
    axes(ax5);
    hold on; grid on; axis equal;
    title('M-PSD 局部二维输出');
    xlabel('u_M (mm)');
    ylabel('v_M (mm)');
    plot_with_point_support(ax5, uv_M_id(1,:),  uv_M_id(2,:),  'r--', '理想轨迹');
    plot_with_point_support(ax5, uv_M_err(1,:), uv_M_err(2,:), 'm-',  '实际轨迹');
    plot(0, 0, 'k+', 'MarkerSize', 10, 'HandleVisibility', 'off');
    legend('show', 'Location', 'best');
    set_axis_by_data(ax5, [uv_M_id(1,:), uv_M_err(1,:)], ...
                          [uv_M_id(2,:), uv_M_err(2,:)], 2);

    % --- ax6: S侧 X-theta ---
    ax6 = handles.ax6;
    cla(ax6);
    axes(ax6);
    hold on; grid on;
    title('S侧 X ~ \theta');
    xlabel('\theta (deg)');
    ylabel('X_{hit} (mm)');
    plot(th_deg, pts_M_to_S_id(1,:),  'r--', 'LineWidth', 1.2, 'DisplayName', '理想');
    plot(th_deg, pts_M_to_S_err(1,:), 'g-',  'LineWidth', 1.5, 'DisplayName', '实际');
    legend('show', 'Location', 'best');

    % --- ax7: M侧 X-theta ---
    ax7 = handles.ax7;
    cla(ax7);
    axes(ax7);
    hold on; grid on;
    title('M侧 X ~ \theta');
    xlabel('\theta (deg)');
    ylabel('X_{hit} (mm)');
    plot(th_deg, pts_S_to_M_id(1,:),  'r--', 'LineWidth', 1.2, 'DisplayName', '理想');
    plot(th_deg, pts_S_to_M_err(1,:), 'm-',  'LineWidth', 1.5, 'DisplayName', '实际');
    legend('show', 'Location', 'best');
end

% ============================================================
% 辅助函数
% ============================================================

function h_edit = add_label_edit(parent, label_str, y_pos, h_lbl, h_edit_box, bg, default_str, fg)
    if nargin < 8
        fg = 'k';
    end

    uicontrol(parent, 'Style', 'text', 'String', label_str, ...
        'Units', 'normalized', 'Position', [0.05, y_pos, 0.90, h_lbl], ...
        'HorizontalAlignment', 'left', 'BackgroundColor', bg, 'ForegroundColor', fg);

    h_edit = uicontrol(parent, 'Style', 'edit', 'String', default_str, ...
        'Units', 'normalized', 'Position', [0.05, y_pos-h_lbl, 0.90, h_edit_box]);
end

function [e_r_out, e_t_out, n_out] = build_box_frame(axis_u, n_r, n_t, roll_ang, pitch_ang, yaw_ang)
    % 初始理想机盒基底
    e_r = n_r / norm(n_r);
    e_t = n_t / norm(n_t);
    n   = axis_u / norm(axis_u);

    % 1) 横滚：绕本机轴线转
    e_r = rodrigues_rot(e_r, n, roll_ang);
    e_t = rodrigues_rot(e_t, n, roll_ang);

    % 2) 俯仰：绕当前切向轴转
    e_r = rodrigues_rot(e_r, e_t, pitch_ang);
    n   = rodrigues_rot(n,   e_t, pitch_ang);

    % 3) 偏航：绕当前径向轴转
    n   = rodrigues_rot(n,   e_r, yaw_ang);
    e_t = rodrigues_rot(e_t, e_r, yaw_ang);

    % 正交化
    n_out   = n / norm(n);
    e_r_out = e_r / norm(e_r);
    e_t_out = cross(n_out, e_r_out);
    e_t_out = e_t_out / norm(e_t_out);

    % 再修正一次 e_r，避免累计误差
    e_r_out = cross(e_t_out, n_out);
    e_r_out = e_r_out / norm(e_r_out);
end

function [P_hit, valid] = line_plane_intersection(P0, d, P_plane, n_plane)
    P_hit = [NaN; NaN; NaN];
    valid = false;

    if norm(d) < 1e-12 || norm(n_plane) < 1e-12
        return;
    end

    d = d / norm(d);
    n = n_plane / norm(n_plane);

    denom = dot(n, d);
    if abs(denom) < 1e-9
        return;
    end

    t = dot(n, (P_plane - P0)) / denom;
    P_hit = P0 + t * d;
    valid = true;
end

function v_rot = rodrigues_rot(v, k, theta)
    if norm(k) < 1e-12
        v_rot = v;
        return;
    end
    k = k / norm(k);
    v_rot = v*cos(theta) + cross(k, v)*sin(theta) + k*dot(k, v)*(1-cos(theta));
end

function set_axis_by_data(ax, xdata, ydata, margin)
    x = xdata(~isnan(xdata));
    y = ydata(~isnan(ydata));

    if isempty(x) || isempty(y)
        xlim(ax, [-1, 1]);
        ylim(ax, [-1, 1]);
        return;
    end

    xmin = min(x); xmax = max(x);
    ymin = min(y); ymax = max(y);

    if abs(xmax - xmin) < 1e-9
        xmin = xmin - 1;
        xmax = xmax + 1;
    end
    if abs(ymax - ymin) < 1e-9
        ymin = ymin - 1;
        ymax = ymax + 1;
    end

    xlim(ax, [xmin - margin, xmax + margin]);
    ylim(ax, [ymin - margin, ymax + margin]);
end

function plot_with_point_support(ax, x, y, style_str, display_name)
    x_valid = x(~isnan(x));
    y_valid = y(~isnan(y));

    if isempty(x_valid) || isempty(y_valid)
        return;
    end

    xr = max(x_valid) - min(x_valid);
    yr = max(y_valid) - min(y_valid);

    if xr < 1e-9 && yr < 1e-9
        plot(ax, x_valid(1), y_valid(1), 'o', ...
            'MarkerSize', 6, 'LineWidth', 1.2, 'DisplayName', display_name);
    else
        plot(ax, x_valid, y_valid, style_str, 'LineWidth', 1.5, 'DisplayName', display_name);
        plot(ax, x_valid(1), y_valid(1), 'o', ...
            'MarkerSize', 4, 'HandleVisibility', 'off');
    end
end