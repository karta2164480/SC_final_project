fileID = fopen('output.txt', 'w');
fprintf(fileID,"{\n");

for i = 1:1500
    fprintf(fileID, '"%d":[\n', i);
    
    route = sprintf("%d\\%d_feature.json",i,i);
    feaFile=route;
    fea=jsondecode(fileread(feaFile));
    pv.pitch=fea.vocal_pitch;
    pv.time=fea.time;
    pv.flux=fea.spectral_flux;
    
    dimension=size(pv.pitch);
    note_count = 1;
    flag = 0;
    time_sector = 1;
    flux_flag=0;
    
    for j = 2:dimension(1)
        
        if(j<dimension(1)&&(pv.flux(j)+pv.flux(j+1)+pv.flux(j-1))/3 > 0.02 &&flux_flag==0)
            flux_flag=1;
        else
            flux_flag=0;
        end
        
        if(pv.pitch(j) ~= 0 && flag == 0)
            result.onset(note_count)=pv.time(j)-0.016;
            pitch(note_count,time_sector)=pv.pitch(j);
            time_sector = time_sector+1;
            flag = 1 ;
            %j = j + 1;
        
        elseif(pv.pitch(j) == 0 && flag == 1)
            result.offset(note_count)=pv.time(j)-0.016;
            result.output(note_count)=trimmean(pitch(note_count),40);
            note_count=note_count+1;
            time_sector = 1;
            flag = 0;
        
        
        elseif((abs(pv.pitch(j)-pv.pitch(j-1)) >= 0.8 || (abs(pv.pitch(j)-pv.pitch(j-1)) >= 0.5&&flux_flag==1))&& flag == 1)
            result.offset(note_count)=pv.time(j)-0.016;
            result.output(note_count)=trimmean(pitch(note_count),40);
            note_count=note_count+1;
            time_sector = 1;
            result.onset(note_count)=pv.time(j)-0.016;
            pitch(note_count,time_sector)=pv.pitch(j);
            flux_flag=2;
        
        elseif(abs(pv.pitch(j)-pv.pitch(j-1))<0.8 && flag == 1)
            pitch(note_count,time_sector)=pv.pitch(j);
            time_sector=time_sector+1;
        end
        
    end
    dimension_result=size(result.onset);
    for j=1:dimension_result(2)-1   
    fprintf(fileID, "[%f,%f,%d],\n", result.onset(j), result.offset(j), round(result.output(j)));
    end
    fprintf(fileID, "[%f,%f,%d]\n",result.onset(dimension_result(2)), result.offset(dimension_result(2)), round(result.output(dimension_result(2))));
    fprintf(fileID, "],\n");
    
    clear pitch;
    clear pv;
    clear fea;
    clear j;
    clear result;
end
fprintf(fileID,"}");
