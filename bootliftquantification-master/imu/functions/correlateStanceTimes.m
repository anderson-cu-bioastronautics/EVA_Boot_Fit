function [times1, times2] = correlateStanceTimes(times1, times2)
        if size(times1,1) < size(times2,1)
            if (abs(times1(1,1)-times2(1,1)) - abs(times1(end,1)-times2(end,1))) > 0
               times2(1,:) = [];             
            elseif (abs(times1(1,1)-times2(1,1)) - abs(times1(end,1)-times2(end,1))) < 0
               times2(end,:) = [];
            end
        elseif size(times1,1) < size(times2,1)
            if (abs(times1(1,1)-times2(1,1)) - abs(times1(end,1)-times2(end,1))) > 0
               times1(1,:) = [];             
            elseif (abs(times1(1,1)-times2(1,1)) - abs(times1(end,1)-times2(end,1))) < 0
               times1(end,:) = [];
            end
        end
end