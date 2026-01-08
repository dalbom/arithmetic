# 간단한 더하기 문제 생성기 (Arithmetic Worksheet Generator)

유치원생/초등학생을 위한 산수 연습 문제지(LaTeX)를 생성하는 도구입니다.

## 설치 (Installation)

필요한 패키지를 설치합니다:
```bash
pip install -r requirements.txt
```

## 사용법 (Usage)

### 방법 1: 웹 인터페이스 (권장)

아이들도 쉽게 사용할 수 있는 웹 인터페이스를 제공합니다:

```bash
streamlit run web_app.py
```

웹 브라우저가 자동으로 열리며, 다음 기능을 사용할 수 있습니다:
- 여러 개의 문제지를 동시에 생성
- 각 문제지마다 다른 설정 적용 (이름, 페이지 수, 문제 유형 등)
- PDF 자동 생성 (로컬 LaTeX 또는 Docker 컨테이너 사용)
- ZIP 파일로 일괄 다운로드

#### PDF 생성 옵션

웹 인터페이스에서 PDF 생성을 위해 두 가지 방법을 지원합니다:

1. **로컬 LaTeX**: MikTeX 또는 TeX Live가 설치되어 있으면 자동으로 감지됩니다.
2. **Docker 컨테이너**: Docker가 설치되어 있으면 `leplusorg/latex` 이미지를 사용하여 PDF를 생성합니다.
   - "Generate PDF using Docker container" 체크박스를 선택하세요.

### 방법 2: 커맨드라인

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
