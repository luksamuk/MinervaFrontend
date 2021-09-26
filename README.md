# Minerva FrontEnd

Criado por Lucas S. Vieira <lucasvieira@protonmail.com>

## Introdução

Este projeto é uma implementação de interface para a o sistema Minerva, feito
em Delphi 11. Seu principal propósito é ser um experimento de uso de FireMonkey
em Delphi, e também avaliar a comunicação REST entre uma aplicação Delphi 11 e
um servidor remoto, totalmente feito em [Rust](https://www.rust-lang.org/).

O Minerva FrontEnd comunica-se com uma API REST do projeto
[Minerva.rs](https://github.com/luksamuk/minerva.rs), obedecendo, portanto às
regras de comunicação da mesma. Isso também serve como um teste de feedback
relacionado a este outro projeto, uma vez que a construção do Front-end de uma
aplicação REST desse tipo acaba por demandar que o Back-end seja bem-documentado.

O Minerva FrontEnd ainda está em sua fase pré-alfa.

## Dependências

Este projeto foi feito em Delphi 11, então é essencial possuir o RAD Studio 11
para compilá-lo.

A única dependência do projeto é a extensão FastReport para FireMonkey, que
possui uma versão grátis que pode ser baixada no
[site oficial](https://www.fast-report.com/pt/product/fast-report-fmx/).

## Licenciamento

Este projeto é redistribuido sob a licença GNU General Public License, versão 3.
Isso significa que o uso comercial desta aplicação está condicionado a certas
determinações legais. Para maiores informações, consulte o arquivo LICENSE
incluido no projeto.

