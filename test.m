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
    time_sector(note_count) = 1;
    flux_flag=0;
    
    for j = 2:dimension(1)
        
        
        if(pv.pitch(j) ~= 0 && flag == 0)
            result.onset(note_count)=pv.time(j);
            pitch(note_count,time_sector(note_count))=round(pv.pitch(j));
            time_sector(note_count) = time_sector(note_count)+1;
            flag = 1 ;

        
        elseif(pv.pitch(j) == 0 && flag == 1)
            result.offset(note_count)=pv.time(j);
            result.output(note_count)=mode(pitch(note_count,1:time_sector(note_count)-1));
            note_count=note_count+1;
            time_sector(note_count) = 1;
            flag = 0;
        
        
        elseif((abs(pv.pitch(j)-pv.pitch(j-1)) >= 0.8 || (j<dimension(1)&&(pv.flux(j)+pv.flux(j+1)+pv.flux(j-1))/3 > 0.04))&& flag == 1 && time_sector(note_count)>4)
            result.offset(note_count)=pv.time(j);
            result.output(note_count)=mode(pitch(note_count,1:time_sector(note_count)-1));
            note_count=note_count+1;
            time_sector(note_count) = 1;
            result.onset(note_count)=pv.time(j);
            pitch(note_count,time_sector(note_count))=round(pv.pitch(j));
            time_sector(note_count)=time_sector(note_count)+1;

        
        elseif(flag == 1)
            pitch(note_count,time_sector(note_count))=round(pv.pitch(j));
            time_sector(note_count)=time_sector(note_count)+1;
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
