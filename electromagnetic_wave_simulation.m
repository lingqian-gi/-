% 参数设置，在这里z<0是媒质1，z>0是媒质2,可以在下方的view函数中更改参数来切换视角，该函数在50行
%注意：由于磁场的大小相对电场较小，故在绘图时将磁场的幅值均放大200倍
w = 2 * pi * 1e9; % 角频率，例如1 GHz
u0=4 * pi *1e-7;%真空磁导率
r0=1e-9/(36 * pi); %真空介电常数
beta1 = w * (u0*r0)^0.5; % 介质1的传播常数
beta2 = w * (u0*r0*2.25)^0.5; % 介质2的传播常数
c = 3e8; % 光速
T =-0.2; % 反射系数
tr =0.8; % 透射系数
n1=120* pi; n2=80*pi; %媒质1和2的波阻抗
Eim= 2; % 当z<0时入射波电场的振幅因子
Him = Eim/n1; % 当z<0时入射波磁场的振幅因子
Erm= Eim*T; % 当z<0时反射波电场的振幅因子
Hrm = Erm/n1; % 当z<0时反射波磁场的振幅因子
Etm= Eim*tr; % 当z<0时反射波电场的振幅因子
Htm = Etm/n2; % 当z<0时反射波磁场的振幅因子

% 时间步长和空间步长
dt = 1e-10; % 时间步长，例如10纳秒
dz = 0.01; % 空间步长，例如0.01米

% 空间和时间范围
z_min = -2; % z的最小值
z_max = 2; % z的最大值
t_max = 10e-9; % 最大时间，例如10纳秒

% 初始化变量
z = z_min:dz:z_max; % z轴上的点
t = 0:dt:t_max; % 时间轴上的点
[Z, T] = meshgrid(z, t); % 创建网格
% 绘制动画
for t_idx = 1:length(t)
    % 当前时间
    current_time = t(t_idx);
    
    % 初始化图形
    clf; % 清除当前图形窗口
    hold on;
    axis equal;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    title(['均匀平面波在理想介质中的传播 Time = ', num2str(current_time * 1e9), ' ns']);
    grid on;
    %使用patch函数绘制z=0平面
    x1 = [z_min z_min z_max z_max];
    y1 = [z_min z_max z_max z_min];
    patch(x1,y1,'g','FaceAlpha', 0.1);
    view(90,0); % 三维视图view(3)/可以通过该函数在平面上电场分量和磁场分量，电场分量为view(180,0),磁场分量为view(90,0)

    % 当z<0时
    z_neg = z(z < 0);
    E_neg = Eim*cos(w * t_idx * dt - beta1 * z_neg)+Erm*cos(w * t_idx * dt + beta1 * z_neg); % 电场（这里使用了t_idx和dt来计算时间）
    H_neg = 200*(Him*cos(w * t_idx * dt - beta1 * z_neg)-Hrm*cos(w * t_idx * dt - beta1 * z_neg)); % 磁场
    
    % 绘制电场（x分量），使用线段表示
    for i = 1:length(z_neg)
        x_start = 0;
        y_start = 0;
        z_start = z_neg(i);
        x_end = E_neg(i) * 0.5; % 乘以一个小因子来表示箭头长度
        y_end = 0;
        z_end = z_start;
        line([x_start x_end], [y_start y_end], [z_start z_end], 'Color', 'r', 'LineWidth', 0.5);
    end
    
    % 绘制磁场（y分量），同样使用线段表示
    for i = 1:length(z_neg)
        x_start = 0;
        y_start = 0;
        z_start = z_neg(i);
        x_end = 0;
        y_end = H_neg(i) * 0.5; % 乘以一个小因子来表示箭头长度
        z_end = z_start;
        line([x_start x_end], [y_start y_end], [z_start z_end], 'Color', 'b', 'LineWidth', 0.5);
    end
    
    % 当z>0时，类似地绘制电场和磁场
    z_pos = z(z >= 0);
    E_pos = Etm * cos(w * t_idx * dt - beta2 * z_pos);
    H_pos = 200*Htm * cos(w * t_idx * dt - beta2 * z_pos);
    
    for i = 1:length(z_pos)
        x_start = 0;
        y_start = 0;
        z_start = z_pos(i);
        x_end = E_pos(i) * 0.5;
        y_end = 0;
        z_end = z_start;
        line([x_start x_end], [y_start y_end], [z_start z_end], 'Color', 'r', 'LineWidth', 0.5);
    end
    
    for i = 1:length(z_pos)
        x_start = 0;
        y_start = 0;
        z_start = z_pos(i);
        x_end = 0;
        y_end = H_pos(i) * 0.5;
        z_end = z_start;
        line([x_start x_end], [y_start y_end], [z_start z_end], 'Color', 'b', 'LineWidth', 0.5);
    end
    
    % 绘制轴线和边界（可选）
    %plot3([-1 1], [0 0], [-1 1], 'k', 'LineWidth', 1); % z轴
    %plot3([-1 1], [-1 1], [0 0], 'k', 'LineWidth', 1); % x-y平面上的边界线
    
    % 保存当前帧到视频
    
    % 暂停一小段时间以模拟动画效果（可选）
    pause(0.01); % 根据设定的帧率调整暂停时间

    % 保存当前帧到视频
    frame = getframe(gcf);
    clf;
end
% 初始化视频对象（需要MATLAB的VideoWriter工具箱）
fps = 1; % 每秒帧数
video = VideoWriter('EM_propagation.avi', 'MPEG-4');
video.FrameRate = fps;
open(video);
writeVideo(video, frame);
close(video);
