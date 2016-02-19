function obj=ufd_multiScaleDetection(integralImages, haarCascade, options)
% This function performs object detection in multiple scales, calling ufd_detect
% function on each scale.
% (Based on code by D. Kroon)

%tira tipo a "media" do padrão de altura e largura da imagem com as imagens estudadas no xml
%como se fosse calcular a escala da imagem
ScaleWidth = integralImages.width/haarCascade.size(1);
ScaleHeight = integralImages.height/haarCascade.size(2);
if(ScaleHeight < ScaleWidth ),                         
  StartScale =  ScaleHeight; 
else
  % decide usar a menor escala como inicial
  StartScale = ScaleWidth;        
end

 %objects é o array para armazenar os quadrados que envolvem as faces quando encontradas e o n é o numero de faces detectadas
obj=zeros(100,4); n=0;                       

%o número de interações possíveis, tipo quantos escalas são possíveis
itt=ceil(log(1/StartScale)/log(options.ScaleUpdate));

for i=1:itt                                           %vai passar de escala por escala pra tentar detectar as faces
  Scale =StartScale*options.ScaleUpdate^(i-1);        %vai vendo primeiro as menores escalas depois vai aumentando
  
  %basicamente checando se a imamgem existe, ou seja, vendo se tem alguma informaçao da imagem 
  if(options.Verbose)                              
    %ele mostra como string a escala e o numero de objetos detectados
    disp(['Scale : ' num2str(Scale) ' objects detected : ' num2str(n)])   
  end
  
  %~~calcula a nova escala para calcular em uma nova dimensao de imagem
  w = floor(haarCascade.size(1)*Scale);                              
  h = floor(haarCascade.size(2)*Scale);                    

  step = floor(max( Scale, 2 ));                           %espaço que o quadrado da cara vai ter

  %~~usa uma matematica ai que cria os vetores que formam os quadrados      
  [x,y]=ndgrid(0:step:(integralImages.width-w-1),0:step:(integralImages.height-h-1)); x=x(:); y=y(:);
  
  %se as coordenadas estiverem vazias, vai procurar já na próxima escala
  if(isempty(x)), continue; end                
  
    [x,y] = OneScaleObjectDetection( x, y, Scale, integralImages, w, h, haarCascade);  %calcula onde vai ficar o quadrado na imagem
    
    for k=1:length(x);                        %no caso viria para ca se as coordenadas de x forem válidas para o rosto em uma imagem
      n=n+1; obj(n,:)=[x(k) y(k) w h];    %aumenta o n, avisando que tem um rosto nessa escala               
    end                                       %object eh para colocar o quadrado nas coordenadas dos vetores encontrados
end                                           

obj=obj(1:n,:);                                

obj=obj*integralImages.Ratio;        %teoricamente redimensiona os quadrados de acordo com a imagem
