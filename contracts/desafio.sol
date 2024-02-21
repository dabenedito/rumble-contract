// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/ToString.sol";

contract DesafioContract {
    using ToString for uint256;

    // Estrutura para representar um desafio
    struct Desafio {
        address desafiante;
        address desafiado;
        address juiz;
        uint256 valorAposta;
        bool desafioAtivo;
        bool desafioAceito;
        address vencedor;
    }

    // Mapeia o endereço do desafiado para os desafios criados por ele
    Desafio[] public desafiosPorDesafiado;

    // Evento para notificar quando um desafio é criado
    event DesafioCriado(address indexed desafiante, address indexed desafiado, uint256 valorAposta);

    // Modificador para garantir que o valor da aposta esteja dentro do intervalo especificado
    modifier valorApostaValido(uint256 _valorAposta) {
        require(_valorAposta >= 0.0017 * (1*10**18) && _valorAposta <= 10**18, "Valor da aposta fora do intervalo permitido");
        _;
    }

    modifier juizValido(address juiz, uint _indexDesafio) {
        require(juiz != desafiosPorDesafiado[_indexDesafio].desafiado, "O desafiado nao pode ser o juiz.");
        require(juiz != desafiosPorDesafiado[_indexDesafio].desafiante, "O desafiante nao pode ser o juiz.");
        _;
    }

    // Função para criar um novo desafio
    function criarDesafio(uint256 _valorAposta) external payable valorApostaValido(_valorAposta) {
        // Garante que o valor enviado seja igual ao valor da aposta
        require(msg.value == _valorAposta, "Valor enviado e diferente do valor da aposta");

        address _desafiado = msg.sender;

        // Deduz o valor da aposta do desafiado
        payable(address(this)).transfer(_valorAposta);

        // Cria o desafio
        Desafio memory novoDesafio = Desafio({
            desafiante: address(0),
            desafiado: _desafiado,
            juiz: address(0),
            valorAposta: _valorAposta,
            desafioAtivo: true,
            desafioAceito: false,
            vencedor: address(0)
        });

        // Adiciona o desafio à lista do desafiado
        desafiosPorDesafiado.push(novoDesafio);

        // Emite o evento de criação do desafio
        emit DesafioCriado(address(0), _desafiado, _valorAposta);
    }

    // Função para aceitar um desafio como desafiante
    function aceitarDesafio(uint256 _indiceDesafio) external payable valorApostaValido(msg.value) {
        // Obtém o desafio da lista do desafiado
        Desafio storage desafio = desafiosPorDesafiado[_indiceDesafio];

        // Garante que o desafio esteja ativo e ainda não tenha sido aceito
        require(desafio.desafioAtivo && !desafio.desafioAceito, "Desafio nao esta ativo ou ja foi aceito");

        // Garante que o valor enviado seja igual ao valor da aposta
        require(msg.value == desafio.valorAposta, "Valor enviado diferente do valor da aposta");

        // Define o desafiante como o chamador da função
        desafio.desafiante = msg.sender;
        payable(address(this)).transfer(desafio.valorAposta);
        // Marca o desafio como aceito
        desafio.desafioAceito = true;
    }

    // Função para o juiz declarar o vencedor
    function declararVencedor(uint256 _indiceDesafio, address _vencedor) external payable  {
        // Somente o juiz pode chamar esta função
        require(msg.sender == desafiosPorDesafiado[_indiceDesafio].juiz, "Somente o juiz pode declarar o vencedor");

        // Obtém o desafio da lista do desafiado
        Desafio storage desafio = desafiosPorDesafiado[_indiceDesafio];

        // Garante que o desafio esteja ativo e tenha sido aceito
        require(desafio.desafioAtivo && desafio.desafioAceito, "Desafio nao esta ativo ou nao foi aceito");

        // Define o vencedor
        desafio.vencedor = _vencedor;

        // Calcula os pagamentos
        uint256 valorPremio = desafio.valorAposta * 8 / 10; // 80% para o vencedor
        uint256 taxaAdministrativa = desafio.valorAposta * 1 / 10; // 10% para fins administrativos
        uint256 pagamentoJuiz = desafio.valorAposta * 1 / 10; // 10% para o juiz

        // Transfere os pagamentos
        payable(_vencedor).transfer(valorPremio);
        payable(desafio.juiz).transfer(pagamentoJuiz);
        payable(address(this)).transfer(taxaAdministrativa); // Taxa administrativa vai para o contrato
    }

    function declararJuiz(uint _indiceDesafio) external juizValido(msg.sender, _indiceDesafio) {
        Desafio storage desafio = desafiosPorDesafiado[_indiceDesafio];
        desafio.juiz = msg.sender;
    }

    function getDesafios() public view returns(Desafio[] memory) {
        return desafiosPorDesafiado;
    }
}
