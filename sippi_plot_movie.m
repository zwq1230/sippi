function sippi_plot_movie(fname,im_array,n_frames,skip_burnin);
% sippi_plot_movie
%
% Call :
%   sippi_plot_movie(fname);
%
% Ex: 
% sippi_plot_movie('20130812_Metropolis');
%
% %% 1000 realization including burn-in, for prior number 1
% sippi_plot_movie('20130812_Metropolis',1,1000,0);
%

if nargin<4, skip_burnin=1;end
if nargin<3, n_frames=100;end


cwd=pwd;

%% DATA
if isstr(fname)
    try
        cd(fname);
        load([fname,'.mat']);
    catch
        load([fname,'.mat']);
    end
    
else
    disp(':/')
    return
end

plotdir=pwd;
try
    fname=options.txt;
end

if ~isfield(options,'FS')
    options.FS=12;
end

if nargin<2
    im_array=1:1:length(prior);
end

%%
options.axis_fontsize=8;
options.width=10;
options.height=10;
options.w0=2;
options.h0=2;

%%
for im=im_array
    disp(im)
    
    ndim=length(find(prior{im}.dim>1));
    if ndim>1 % ONLY PLOT MOVIE FOR 2D and 3D PARAMETERS
        
        N=prod(prior{im}.dim);
        
        if skip_burnin
            i1=ceil(prior{1}.seq_gibbs.i_update_step_max/mcmc.i_sample);
        else
            i1=1;
        end
        ns=mcmc.nite/mcmc.i_sample;
        n_frames=min([n_frames (ns-i1)]);
        i_frames=ceil(linspace(i1,ns,n_frames));
        
        
        %% POSTERIOR
        vname=sprintf('%s_m%d_posterior.mp4',options.txt,im);
        try
            if exist(vname,'file');
                delete(vname);
            end
        end
        
        writerObj = VideoWriter(vname,'MPEG-4');
        writerObj.Quality=100;
        open(writerObj);
        
        fname=sprintf('%s_m%d.asc',options.txt,im);
        fid=fopen(fname,'r');
        
        i=0;
        while ~feof(fid);
            i=i+1;
            d=fscanf(fid,'%g',N);
            
            if ~isempty(find(i==i_frames))
                if prior{im}.dim(3)>1
                    % 3D
                    real=reshape(d,length(prior{im}.y),length(prior{im}.x),length(prior{im}.z));
                elseif prior{im}.dim(2)>1
                    % 2D
                    real=reshape(d,length(prior{im}.y),length(prior{im}.x));
                else
                    % 1D
                    real=d;
                end
                m{im}=real;
                
                sippi_plot_model(prior,m,im);
                text(.02,.02,sprintf('#%05d',i),'units','normalized')
                drawnow;
                frame = getframe;
                writeVideo(writerObj,frame);
            end
        end
        close(writerObj);
        fclose(fid);
        
        %% PRIOR
        vname=sprintf('%s_m%d_prior.mp4',options.txt,im);
        try
            if exist(vname,'file');
                delete(vname);
            end
        end
        
        writerObj = VideoWriter(vname,'MPEG-4');
        writerObj.Quality=100;
        open(writerObj);
        
        for i=1:length(i_frames)
            m=sippi_prior(prior,m);
            sippi_plot_model(prior,m,im);
            text(.02,.02,sprintf('#%05d',i),'units','normalized')
            drawnow;
            frame = getframe;
            writeVideo(writerObj,frame);
        end
        close(writerObj);
    
        
    end
end
%%
cd(cwd)