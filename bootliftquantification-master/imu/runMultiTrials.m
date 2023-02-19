function runMultiTrials()
%parpool(6)
for subject = 2:4
    for c = 0:2
        try
            parfor t = 1:30
                try
                    main(subject,c,t,'l',1)
                catch
                end
                try
                    main(subject,c,t,'r',1)
                catch
                end
            end
        catch
        end

    end
end
end