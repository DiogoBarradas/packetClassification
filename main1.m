
function main1 ()
classifier('1-labeled.dat');
classifier('2-labeled.dat');
classifier('3-labeled.dat');
classifier('4-labeled.dat');
end

function classifier(dat)

p2p=importdata(dat);
p2p=string(p2p);

vetores=transforma_doc(p2p);

ips=vetores(1:10000);
conections=vetores(10001:20000);
bw=vetores(20001:30000);
packet_size=vetores(30001:40000);
time=vetores(40001:50000);
result=vetores(50001:60000);

%filtra vetores tirando valores repetidos
novo_ips=filtraVetor(ips);
novo_conections=filtraVetor(conections);
novo_bw=filtraVetor(bw);
novo_packet_size=filtraVetor(packet_size);
novo_time=filtraVetor(time);

%count do total p2p / n p2p
total_p2p=0;
total_np2p=0;
for b=1:size(result,2)
    if strcmp(result(b),",p2p")
        total_p2p=total_p2p+1;
    else
        total_np2p=total_np2p+1;
    end
end

totais=[total_p2p,total_np2p];

%probabilidade de cada acontecimento para variveis independentes
prob_ips=probabilidade_dup(ips,novo_ips,result,totais);
prob_conections=probabilidade_dup(conections,novo_conections,result,totais);
prob_bw=probabilidade_dup(bw,novo_bw,result,totais);
prob_packet_size=probabilidade_dup(packet_size,novo_packet_size,result,totais);
prob_time=probabilidade_dup(time,novo_time,result,totais);

%probabilidade p2p /np2p
prob_total_p2p=total_p2p/10000;
prob_total_np2p=total_np2p/10000;

    add= erase(dat,'-labeled.dat');
    original='-unlabeled.dat';
    unlabeled=strcat(add,original);
    classifica(unlabeled,prob_ips,prob_conections,prob_bw,prob_packet_size,prob_time,prob_total_p2p,prob_total_np2p);

end%function main

%divide em vetores cada tipo de atributos
function vetores = transforma_doc (doc)
ips = [""];
conections = [""];
bw = [""];
packet_size = [""];
time = [""];
result = [""];

    for i=1:size(doc)

        [doc(i,1),doc(i,2)]=strtok(doc(i),',');
        ips(i)=doc(i,1);
        [doc(i,2),doc(i,3)]=strtok(doc(i,2),',');
        conections(i)=doc(i,2);
        [doc(i,3),doc(i,4)]=strtok(doc(i,3),',');
        bw(i)=doc(i,3);
        [doc(i,4),doc(i,5)]=strtok(doc(i,4),',');
        packet_size(i)=doc(i,4);
        [doc(i,5),doc(i,6)]=strtok(doc(i,5),',');
        time(i)=doc(i,5);
        result(i)=doc(i,6);    
        
        vetores=[ips,conections,bw,packet_size,time,result];
    end 
end

%classifica amostra comparando com a matriz probabilidade de cada tipo de
%atributo dado como argumento
function classifica (ficheiro_unlabeled, prob_ips, prob_conections, prob_bw, prob_packet_size, prob_time,prob_total_p2p,prob_total_np2p)

ficheiro=importdata(ficheiro_unlabeled);
ficheiro=string(ficheiro);
vetores=transforma_doc(ficheiro);

ips_p2p=0;
ips_np2p=0;
conections_p2p=0;
conections_np2p=0;
bw_p2p=0;
bw_np2p=0;
packet_size_p2p=0;
packet_size_np2p=0;
time_p2p=0;
time_np2p=0;
        
ips=vetores(1:5000);
conections=vetores(5001:10000);
bw=vetores(10001:15000);
packet_size=vetores(15001:20000);
time=vetores(20001:25000);
        
        fid=ficheiro_unlabeled;
        fid = erase(fid,'un');
        add='out-';
        fid = strcat(add,fid);

        fid=fopen(fid,'wt');
        
        
   
    for i=1:5000
        
        for j=1:size(prob_ips,2)
            
            if strcmp (ips(i),prob_ips{j,1})
                ips_p2p=prob_ips{j,2};
                ips_np2p=prob_ips{j,3};
                break;
            end
        end

        for k=1:size(prob_conections,2)
            if strcmp (conections(i),prob_conections{k,1})
                conections_p2p=prob_conections{k,2};
                conections_np2p=prob_conections{k,3};
            end
        end

        for l=1:size(prob_bw,2)
           if strcmp (bw(i),prob_bw{l,1})
               bw_p2p=prob_bw{l,2};
               bw_np2p=prob_bw{l,3};
           end
        end

        for m=1:size(prob_packet_size,2)
            if strcmp (packet_size(i),prob_packet_size{m,1})
                packet_size_p2p=prob_packet_size{m,2};
                packet_size_np2p=prob_packet_size{m,3};
            end
        end

        for n=1:size(prob_time,2)
            if strcmp (time(i),prob_time{n,1})
                time_p2p=prob_time{n,2};
                time_np2p=prob_time{n,3};
            end
        end
        
        prob_p2p=ips_p2p*conections_p2p*bw_p2p*packet_size_p2p*time_p2p*prob_total_p2p;
        prob_np2p=ips_np2p*conections_np2p*bw_np2p*packet_size_np2p*time_np2p*prob_total_np2p;
        
            if prob_p2p>prob_np2p
                ficheiro(i)=ficheiro{i}+",p2p\n";
                fprintf(fid,ficheiro(i));
            else
                ficheiro(i)=ficheiro{i}+",not p2p\n";
                fprintf(fid,ficheiro(i));
            end     
    end
        fclose(fid);  
end
    
%cria matriz probabilidade p2p/ np2p para cada atributo
function probabilidade = probabilidade_dup (vetor_inicial,vetor_unicos,vetor_p2p,totais)
    
    for i=1:size(vetor_unicos,2)
        count_p2p=0;
        count_np2p=0;
        valor=vetor_unicos(i);
        for j=1:size(vetor_inicial,2)
            if strcmp(valor,vetor_inicial(j))
                
                if strcmp(vetor_p2p(j),",p2p")
                    count_p2p=count_p2p+1;
                elseif strcmp(vetor_p2p(j),",not p2p")
                    count_np2p=count_np2p+1;
                end
            end
        end
        probabilidade{i,1}=vetor_unicos(i);
        probabilidade{i,2}=count_p2p/totais(1);
        probabilidade{i,3}=count_np2p/totais(2);
    end    
end

function unicos = filtraVetor(vetor)
%filtra para novo vetor os valores únicos

unicos=[];
flag=0;

    for i=1:size(vetor,2)
        valor=vetor(i);
        for j=1:size(unicos,2)
            if strcmp(unicos(j),valor)
                flag=1;
                break;
            end
        end
        if flag==0
            unicos=[unicos,valor];
        end
        flag=0;
    end  
end