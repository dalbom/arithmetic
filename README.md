# 간단한 더하기 문제 생성기 (Arithmetic Worksheet Generator)

유치원생/초등학생을 위한 산수 연습 문제지(LaTeX)를 생성하는 도구입니다.

## 설치 (Installation)

필요한 패키지를 설치합니다:
```bash
pip install -r requirements.txt
```

## 사용법 (Usage)

1. `config.yaml` 파일을 작성하여 설정을 정의합니다.
2. 스크립트를 실행합니다:
```bash
python arithmetic_generator.py
```
3. 생성된 `.tex` 파일을 LaTeX 편집기(Overleaf 등)에서 컴파일하여 PDF로 만듭니다.

## 설정 (Configuration)

`config.yaml` 파일에서 생성할 문제지의 종류와 내용을 설정할 수 있습니다.

```yaml
generations:
  - output: "luna.tex"        # 저장할 파일명
    n_page: 10                # 생성할 페이지 수
    page_offset: 51           # 시작 페이지 번호
    problems:
      - type: "addition"      # 문제 유형
        operands: [2, 1]      # 2자리 + 1자리
        questions_per_page: 10 # 페이지당 이 유형의 문제 수
      - type: "addition"
        operands: [1, 1]      # 1자리 + 1자리
        questions_per_page: 4  # 페이지당 이 유형의 문제 수 (총 14문제/페이지)

  - output: "juna.tex"
    n_page: 10
    page_offset: 51
    # questions_per_page: 20  # (선택) 문제별 개수가 지정되지 않았을 때의 기본값
    problems:
      - type: "addition"
        operands: [2, 2]      # 2자리 + 2자리
        questions_per_page: 20
```

### Easy Mode (쉬운 모드)

`subtraction`과 `division` 문제에는 `easymode` 옵션을 사용할 수 있습니다:

- **subtraction (뺄셈)**: `easymode: true`로 설정하면 결과가 항상 0 이상이 됩니다 (음수 없음).
- **division (나눗셈)**: `easymode: true`로 설정하면 결과가 항상 정수가 됩니다 (나머지 없음).

```yaml
problems:
  - type: "subtraction"
    operands: [2, 1]
    questions_per_page: 10
    easymode: true          # 음수 결과 없음 (항상 A >= B)

  - type: "division"
    operands: [1, 1]
    questions_per_page: 10
    easymode: true          # 정수 결과만 (나머지 없음)
```

`easymode` 옵션이 없거나 `false`로 설정된 경우, 피연산자는 무작위로 선택됩니다.
