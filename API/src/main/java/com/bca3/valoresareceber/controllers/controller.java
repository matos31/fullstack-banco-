package com.bca3.valoresareceber.controllers;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

import com.bca3.valoresareceber.dto.ValorDTO;
import com.bca3.valoresareceber.dto.ValoresReceberRequestDTO;
import com.bca3.valoresareceber.models.LogConsulta;
import com.bca3.valoresareceber.models.ValoresReceber;
import com.bca3.valoresareceber.repository.LogConsultaRepository;
import com.bca3.valoresareceber.repository.ProponenteRepository;
import com.bca3.valoresareceber.repository.ValoresReceberRepository;
import com.bca3.valoresareceber.models.Proponente;
import com.bca3.valoresareceber.utils.CpfUtils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
//dada dds
@RestController
@RequestMapping("/valores-a-receber")
@Validated
public class controller {

    @Autowired
    private ProponenteRepository proponenteRepository;

    @Autowired
    private ValoresReceberRepository valoresReceberRepository;

    @Autowired
    private LogConsultaRepository logConsultaRepository;

    @GetMapping("/valores")
    public ResponseEntity<?> consultarValores(@RequestParam String cpf, @RequestParam LocalDate dta_nasc) {
        if (!CpfUtils.isValid(cpf)) {
            Map<String, Object> response = new HashMap<>();
            response.put("Erro", "Campo inválido");
            response.put("Mensagem", "CPF do proponente inválido, verifique e tente novamente");
            return ResponseEntity.badRequest().body(response);
        }

        Optional<Proponente> proponenteOpt = proponenteRepository.findByCpf(cpf);
        Map<String, Object> response = new HashMap<>();
        response.put("CPF proponente", cpf);
        List<ValorDTO> valoresDTO = new ArrayList<>();

        if (proponenteOpt.isEmpty()) {
            salvarLog(cpf, false, false);
            response.put("mensagem", "Proponente não encontrado, verifique se o CPF foi digitado corretamente");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }

        Proponente proponente = proponenteOpt.get();
        List<ValoresReceber> valores = valoresReceberRepository.findByProponenteId(proponente.getId());
        valoresDTO.addAll(valores.stream().map(valor -> new ValorDTO(
                valor.getNomeInstituicao(),
                valor.getCnpj(),
                valor.getValor(),
                valor.getTipoValor(),
                valor.getObservacao(),
                valor.getDtaReferencia()
        )).toList());

        response.put("Nome proponente", proponente.getNome());
        response.put("valores_a_receber", valoresDTO);

        if (valores.isEmpty()) {
            salvarLog(cpf, true, false);
            response.put("Possui_valores_receber", false);
            return ResponseEntity.ok(response);
        }

        response.put("Possui_valores_receber", true);
        salvarLog(cpf, true, true);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/proponente")
    @ResponseStatus(HttpStatus.CREATED)
    public Proponente adicionarProp(@RequestBody Proponente proponente) {
        return proponenteRepository.save(proponente);
    }

    @PostMapping("/valores")
    public ResponseEntity<?> adicionarVal(@RequestBody ValoresReceberRequestDTO dto) {
        if (!CpfUtils.isValid(dto.cpf)) {
            Map<String, Object> response = new HashMap<>();
            response.put("Erro", "Campo inválido");
            response.put("Mensagem", "CPF do proponente inválido, verifique e tente novamente");
            return ResponseEntity.badRequest().body(response);
        }

        Optional<Proponente> proponenteOpt = proponenteRepository.findByCpf(dto.cpf);

        if (proponenteOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Proponente com ID informado não encontrado.");
        }

        ValoresReceber valor = new ValoresReceber();
        valor.setNomeInstituicao(dto.nomeInstituicao);
        valor.setCnpj(dto.cnpj);
        valor.setValor(dto.valor);
        valor.setTipoValor(dto.tipoValor);
        valor.setObservacao(dto.observacao);
        valor.setDtaReferencia(dto.dtaReferencia);
        valor.setProponente(proponenteOpt.get());

        ValoresReceber salvo = valoresReceberRepository.save(valor);
        return ResponseEntity.status(HttpStatus.CREATED).body(salvo);
    }

    @GetMapping("/proponentes")
    public ResponseEntity<List<Proponente>> listarProponentes() {
        List<Proponente> lista = proponenteRepository.findAll();
        return ResponseEntity.ok(lista);
    }

    private void salvarLog(String cpf, boolean propBanco, boolean possuiValores) {
        LogConsulta log = new LogConsulta();
        log.setDtaConsulta(LocalDateTime.now());
        log.setCpfConsultado(cpf);
        log.setPropNoBanco(propBanco);
        log.setPossuiValores(possuiValores);
        logConsultaRepository.save(log);
    }
}
