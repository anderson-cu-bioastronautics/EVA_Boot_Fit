function euler = quart2euler(quat)
% QUAT2EULER convert quaternions to Euler angles
%   eulerAngles = quart2euler(quaternions)
    euler = zeros(length(quat), 3);
    euler(:,1) = atan2(2.*(quat(:,1).*quat(:,2)+quat(:,3).*quat(:,4)),(1-2.*(quat(:,2).^2+quat(:,3).^2)));
    euler(:,2) = asin(2.*(quat(:,1).*quat(:,3)-quat(:,4).*quat(:,2)));
    euler(:,3) = atan2(2.*(quat(:,1).*quat(:,4)+quat(:,2).*quat(:,3)),(1-2.*(quat(:,3).^2+quat(:,4).^2)));
end