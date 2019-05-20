# CameraBio

Este projeto visa facilitar a integração do processo de captura biometrica via aplicativos iOS para os clientes Acesso. 

## Começando

Estas instrucoes farao com que voce consiga implementar a camera com engenharia biométrica pré-existente e obter/manipular os dados de retorno.

### Pré requisitos

Xcode - IDE oficial de desenvolvimento Apple. - Versão 9 ou superior
CocoaPods - Gerenciador de bibiotecas para IDE

Siga a documentação cocoa para instalar o gerenciador em sua maquina caso ainda a possua. 

### Instalando

Recomendamos o uso do cocoapods para o desenvolvimento da aplicação. 

- Abra o terminal e navegue até o diretório raiz da aplicação.
- Na raiz, digite no terminal: 

```
pod init 
```

Um arquivo de Pods será criado em seu diretório, abra o mesmo e adicione:

```
pod ‘CameraBio’, :git => ‘https://github.com/acesso-io/acessobio-camerabio’, :tag => ‘0.0.3’
```

Em seguida: 

```
pod install
```

Pronto! A nossa SDK já esta adicionada em seu projeto e pronta para uso. 

## Manuseio

Para importar, abrir e receber os callbacks básicos e muito simples, siga os passos abaixo: 

```
#import <CameraBio/CameraBiometry.h>
```

```
 CameraBio *cameraBio = [[CameraBio alloc]initWithViewController:self];     
 [cam startCamera];
```

Obter a imagem em base64:

```
 - (void)onSuccesCapture: (NSString*)base64;
```

### Outros métodos uteis

Explain what these tests test and why

```
Give an example
```


## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [MLKit](https://firebase.google.com/docs/ml-kit/?hl=pt-br) - Framework Google para reconhecimento facial

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Matheus Domingos** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)
* **Rafael Martins** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


