# CameraBio

Este projeto visa facilitar a integração do processo de captura biométrica via aplicativos iOS para os clientes Acesso. 

## Começando

Estas instruções farão com que você consiga implementar a câmera com engenharia biométrica pré-existente e obter/manipular os dados de retorno.

### Pré requisitos

 - Xcode - IDE oficial de desenvolvimento Apple. Versão 9 ou superior
 - CocoaPods - Gerenciador de bibiotecas para IDE

Siga a documentação [cocoapods](https://cocoapods.org/) para instalar o gerenciador em sua maquina caso ainda a possua. 


Caso ainda não possua as permissões para o uso de câmera em seu projeto, nao esqueça de adicionar antes de compilar o sua aplicação. Segue o exemplo: 

```
<key>NSCameraUsageDescription</key>
<string>Camera usage description</string>
```

### Instalando

Recomendamos o uso do cocoapods para o desenvolvimento da aplicação. 

- Abra o terminal e navegue até o diretório raiz da aplicação.
- Na raiz, digite no terminal: 

```
pod init 
```

![](https://media.giphy.com/media/QCCiKSwfM8wuyYPaOI/giphy.gif)

- Um arquivo Podfile será criado em seu diretório.

![](https://media.giphy.com/media/SsgTAziSaHmH84BASS/giphy.gif)


- Abra o mesmo e adicione:
```
pod ‘CameraBio’, :git => ‘https://github.com/acesso-io/acessobio-camerabio’, :tag => ‘1.0.2’
```
![](https://media.giphy.com/media/eK6aukS7LdEOv0NFgC/giphy.gif)

Em seguida, volte ao terminal e adicione a seguinte linha: 

```
pod install
```
![](https://media.giphy.com/media/f7Z6XiHwXK1a7lq8VT/giphy.gif)

Pronto! A nossa SDK já esta adicionada e pronta para uso. 

## Manuseio

Importar, abrir a câmera e receber os callbacks básicos é muito simples, siga os passos abaixo:

- Abra o seu arquivo *.h* que deseja abrir a camera de captura e importe importe e implemente nossa classe: 

```
#import <CameraBio/CameraBiometry.h>

@interface ViewController : UIViewController <CameraBioDelegate>
```

- No arquivo *.m* instancie e chame a abertura de câmera:

```
CameraBio *cameraBio = [[CameraBio alloc]initWithViewController:self];     
[cameraBio setDelegate:self];
[cameraBio startCamera];
```

- Implemente no mesmo arquivo o método abaixo para obter a imagem em base64:

```
- (void)onSuccesCapture: (NSString*)base64;
```
## Construido com

* [MLKit](https://firebase.google.com/docs/ml-kit/?hl=pt-br) - Framework Google para reconhecimento facial


## Versionamento

We use [Github](https://github.com/) para versionar. Para as versões disponíveis, veja as [tags do repositório](https://github.com/acesso-io/acessobio-camerabio/releases). 

## Autores

* **Matheus Domingos** - *Engenheiro iOS* - [GitHub](https://github.com/MatheusDomingos)
* **Rafael Martins** - *Engenheiro Android* - [GitHub](https://github.com/rafaelmartinsdacosta)

Veja também nossa lista de [contribuidores](https://github.com/your/project/contributors) que participaram deste projeto.

## Licença

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


