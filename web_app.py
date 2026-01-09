"""
Arithmetic Worksheet Generator - Web Interface
A child-friendly web interface for generating math worksheets using TeXLive.net API.
"""

import streamlit as st
import requests
import zipfile
import tempfile
import os
import re
from io import BytesIO
from arithmetic_generator import generate_latex


# ============================================================================
# INTERNATIONALIZATION (i18n)
# ============================================================================

TRANSLATIONS = {
    "en": {
        # Page title
        "page_title": "Math Worksheet Generator",
        
        # Headers
        "main_header": "🧮 Math Worksheet Generator 📝",
        "sub_header": "Create fun math practice sheets for kids! 🎉",
        
        # Sidebar
        "language_label": "🌐 Language",
        "pdf_options": "⚙️ PDF Options",
        "generate_pdf_checkbox": "📄 Generate PDF files",
        "generate_pdf_help": "Convert .tex files to PDF using TeXLive.net API",
        
        # Worksheet configuration
        "configure_worksheets": "📚 Configure Your Worksheets",
        "configure_worksheets_desc": "Add worksheets for different children or difficulty levels!",
        "add_worksheet": "➕ Add Worksheet",
        "worksheet_name_label": "📛 Child's Name or Worksheet Title",
        "worksheet_name_help": "Give this worksheet a fun name! (This will also be the filename)",
        "num_pages_label": "📄 Number of Pages",
        "num_pages_help": "How many pages of practice?",
        "start_page_label": "🔢 Starting Page Number",
        "start_page_help": "What number should the first page show?",
        
        # Problem types
        "problem_types_header": "🎲 Problem Types",
        "problem_types_desc": "Add different types of math problems to this worksheet!",
        "add_problem_type": "➕ Add Problem Type",
        "problem_type_n": "Problem Type",
        "type_label": "Type",
        "addition": "➕ Addition",
        "subtraction": "➖ Subtraction",
        "multiplication": "✖️ Multiplication",
        "division": "➗ Division",
        "first_digits_label": "First Number Digits",
        "first_digits_help": "How many digits in the first number?",
        "second_digits_label": "Second Number Digits",
        "second_digits_help": "How many digits in the second number?",
        "questions_per_page_label": "Questions Per Page",
        "questions_per_page_help": "How many of this type per page?",
        "easy_mode": "🌟 Easy Mode",
        "easy_mode_help": "No negative answers (subtraction) or no remainders (division)",
        "delete_worksheet": "🗑️ Delete This Worksheet",
        
        # Generate section
        "generate_header": "🎯 Generate Worksheets",
        "generate_button": "🚀 Generate All Worksheets!",
        "no_worksheets_error": "No worksheets configured!",
        
        # Progress messages
        "generating": "📝 Generating",
        "converting_to_pdf": "📄 Converting {name} to PDF (via TeXLive.net)...",
        "pdf_generated": "✅ {name} PDF generated!",
        "pdf_failed": "❌ PDF generation failed for {name}: {error}",
        "error_generating": "❌ Error generating {name}: {error}",
        "all_done": "✨ All done!",
        
        # Download section
        "download_header": "📥 Download Your Files",
        "download_file": "⬇️ Download {filename}",
        "download_all_zip": "📦 Download All (ZIP)",
        "individual_files": "**Individual files:**",
        
        # Footer
        # Footer
        "footer_text": "PDF compilation service provided by <a href='https://texlive.net/' target='_blank'>TeXLive.net</a> | Made by <a href='https://sites.google.com/view/haebomme/home' target='_blank'>dalbom</a>"
    },
    "ko": {
        # Page title
        "page_title": "수학 문제지 생성기",
        
        # Headers
        "main_header": "🧮 수학 문제지 생성기 📝",
        "sub_header": "아이들을 위한 재미있는 수학 연습 문제지를 만들어요! 🎉",
        
        # Sidebar
        "language_label": "🌐 언어",
        "pdf_options": "⚙️ PDF 옵션",
        "generate_pdf_checkbox": "📄 PDF 파일 생성",
        "generate_pdf_help": "TeXLive.net API를 사용하여 .tex 파일을 PDF로 변환합니다.",
        
        # Worksheet configuration
        "configure_worksheets": "📚 문제지 설정",
        "configure_worksheets_desc": "아이들마다 다른 문제지를 추가해보세요!",
        "add_worksheet": "➕ 문제지 추가",
        "worksheet_name_label": "📛 아이 이름 또는 문제지 제목",
        "worksheet_name_help": "재미있는 이름을 지어주세요! (파일명으로도 사용됩니다)",
        "num_pages_label": "📄 페이지 수",
        "num_pages_help": "몇 페이지의 연습문제를 만들까요?",
        "start_page_label": "🔢 시작 페이지 번호",
        "start_page_help": "첫 페이지에 표시될 번호는?",
        
        # Problem types
        "problem_types_header": "🎲 문제 유형",
        "problem_types_desc": "다양한 종류의 수학 문제를 추가하세요!",
        "add_problem_type": "➕ 문제 유형 추가",
        "problem_type_n": "문제 유형",
        "type_label": "유형",
        "addition": "➕ 덧셈",
        "subtraction": "➖ 뺄셈",
        "multiplication": "✖️ 곱셈",
        "division": "➗ 나눗셈",
        "first_digits_label": "첫 번째 숫자 자릿수",
        "first_digits_help": "첫 번째 숫자는 몇 자리?",
        "second_digits_label": "두 번째 숫자 자릿수",
        "second_digits_help": "두 번째 숫자는 몇 자리?",
        "questions_per_page_label": "페이지당 문제 수",
        "questions_per_page_help": "이 유형의 문제를 페이지당 몇 개?",
        "easy_mode": "🌟 쉬운 모드",
        "easy_mode_help": "음수 없음(뺄셈) 또는 나머지 없음(나눗셈)",
        "delete_worksheet": "🗑️ 이 문제지 삭제",
        
        # Generate section
        "generate_header": "🎯 문제지 생성",
        "generate_button": "🚀 모든 문제지 생성!",
        "no_worksheets_error": "설정된 문제지가 없습니다!",
        
        # Progress messages
        "generating": "📝 생성 중",
        "converting_to_pdf": "📄 {name}을(를) PDF로 변환 중 (TeXLive.net 서비스 이용)...",
        "pdf_generated": "✅ {name} PDF 생성 완료!",
        "pdf_failed": "❌ {name} PDF 생성 실패: {error}",
        "error_generating": "❌ {name} 생성 오류: {error}",
        "all_done": "✨ 모두 완료!",
        
        # Download section
        "download_header": "📥 파일 다운로드",
        "download_file": "⬇️ {filename} 다운로드",
        "download_all_zip": "📦 전체 다운로드 (ZIP)",
        "individual_files": "**개별 파일:**",
        
        # Footer
        # Footer
        "footer_text": "PDF 컴파일 서비스는 <a href='https://texlive.net/' target='_blank'>TeXLive.net</a>에서 제공합니다. | Made by <a href='https://sites.google.com/view/haebomme/home' target='_blank'>dalbom</a>"
    }
}


def t(key, **kwargs):
    """Get translated string for current language."""
    lang = st.session_state.get('language', 'en')
    translations = TRANSLATIONS.get(lang, TRANSLATIONS['en'])
    text = translations.get(key) if translations else None
    if text is None:
        text = TRANSLATIONS['en'].get(key, key)
    if text and kwargs:
        text = text.format(**kwargs)
    return text or key


def get_problem_type_display(problem_type):
    """Get display name for problem type."""
    type_map = {
        "addition": t("addition"),
        "subtraction": t("subtraction"),
        "multiplication": t("multiplication"),
        "division": t("division")
    }
    return type_map.get(problem_type, problem_type)


# ============================================================================
# PAGE CONFIGURATION
# ============================================================================

st.set_page_config(
    page_title="🧮 Math Worksheet Generator",
    page_icon="🧮",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for child-friendly interface
st.markdown("""
<style>
    /* Make the interface more colorful and child-friendly */
    .stApp {
        background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    }
    
    .main-header {
        text-align: center;
        color: #2e7d32;
        font-size: 2.5rem;
        margin-bottom: 1rem;
    }
    
    .sub-header {
        text-align: center;
        color: #1565c0;
        font-size: 1.2rem;
        margin-bottom: 2rem;
    }
    
    /* Colorful cards for worksheets */
    .worksheet-card {
        background: white;
        border-radius: 15px;
        padding: 20px;
        margin: 10px 0;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        border-left: 5px solid #4CAF50;
    }
    
    /* Fun button styling */
    .stButton > button {
        background: linear-gradient(45deg, #4CAF50, #8BC34A);
        color: white;
        font-size: 1.2rem;
        font-weight: bold;
        border-radius: 25px;
        padding: 0.5rem 2rem;
        border: none;
        transition: transform 0.2s;
    }
    
    .stButton > button:hover {
        transform: scale(1.05);
    }
    
    /* Colorful number inputs */
    .stNumberInput > div > div > input {
        border-radius: 10px;
        border: 2px solid #64B5F6;
    }
    
    /* Fun selectbox */
    .stSelectbox > div > div {
        border-radius: 10px;
    }
    
    /* Emoji headers */
    h1, h2, h3 {
        color: #37474F;
    }
    
    .problem-type-header {
        font-size: 1.3rem;
        color: #1976D2;
        margin-top: 1rem;
    }
    
    .footer {
        position: fixed;
        left: 0;
        bottom: 0;
        width: 100%;
        background-color: transparent;
        color: #555;
        text-align: center;
        padding: 10px;
        font-size: 0.9rem;
    }
</style>
""", unsafe_allow_html=True)


# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

def compile_tex_with_texlivenet(tex_content):
    """Compile LaTeX content to PDF using TeXLive.net API."""
    try:
        response = requests.post(
            "https://texlive.net/cgi-bin/latexcgi",
            files={
                "filename[]": (None, "document.tex"),
                "filecontents[]": (None, tex_content),
                "return": (None, "pdf"),
            },
            timeout=60
        )
        
        if response.status_code == 200 and response.headers.get('content-type') == 'application/pdf':
            return True, response.content
        else:
            return False, response.text[:500] if response.text else "Unknown error from API"
    except Exception as e:
        return False, str(e)


def create_zip_from_files(file_dict):
    """Create a zip file from a dictionary of {filename: content}."""
    zip_buffer = BytesIO()
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
        for filename, content in file_dict.items():
            if isinstance(content, bytes):
                zip_file.writestr(filename, content)
            else:
                zip_file.writestr(filename, content.encode('utf-8'))
    zip_buffer.seek(0)
    return zip_buffer


# ============================================================================
# MAIN APPLICATION
# ============================================================================

def main():
    # Initialize language in session state
    if 'language' not in st.session_state:
        st.session_state.language = 'en'
    
    # Sidebar with language and PDF options
    with st.sidebar:
        # Language selection at the top
        st.markdown(f"## {t('language_label')}")
        language_options = {"English": "en", "한국어": "ko"}
        current_lang_display = "English" if st.session_state.language == "en" else "한국어"
        
        selected_lang = st.selectbox(
            t("language_label"),
            options=list(language_options.keys()),
            index=list(language_options.keys()).index(current_lang_display),
            label_visibility="collapsed"
        )
        
        if language_options[selected_lang] != st.session_state.language:
            st.session_state.language = language_options[selected_lang]
            st.rerun()
        
        st.markdown("---")
        
        st.markdown(f"## {t('pdf_options')}")
        
        generate_pdf = st.checkbox(
            t("generate_pdf_checkbox"),
            value=True,
            help=t("generate_pdf_help")
        )
    
    # Header with fun emojis
    st.markdown(f'<h1 class="main-header">{t("main_header")}</h1>', unsafe_allow_html=True)
    st.markdown(f'<p class="sub-header">{t("sub_header")}</p>', unsafe_allow_html=True)
    
    # Initialize session state for worksheets
    if 'worksheets' not in st.session_state:
        st.session_state.worksheets = [create_default_worksheet("Worksheet 1")]
    
    # Main content area
    st.markdown(f"## {t('configure_worksheets')}")
    st.markdown(t("configure_worksheets_desc"))
    
    # Add worksheet button
    col1, col2, col3 = st.columns([1, 1, 2])
    with col1:
        if st.button(t("add_worksheet"), use_container_width=True):
            new_name = f"Worksheet {len(st.session_state.worksheets) + 1}"
            st.session_state.worksheets.append(create_default_worksheet(new_name))
            st.rerun()
    
    # Display each worksheet configuration
    for idx, worksheet in enumerate(st.session_state.worksheets):
        with st.expander(f"📝 {worksheet['name']}", expanded=(idx == 0)):
            render_worksheet_config(idx, worksheet)
    
    # Generate button
    st.markdown("---")
    st.markdown(f"## {t('generate_header')}")
    
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        generate_button = st.button(
            t("generate_button"),
            use_container_width=True,
            type="primary"
        )
    
    if generate_button:
        generate_worksheets(generate_pdf)
    
    # Footer
    st.markdown(f"""
        <div class="footer">
            {t('footer_text')}
        </div>
    """, unsafe_allow_html=True)


def create_default_worksheet(name):
    """Create a default worksheet configuration."""
    return {
        'name': name,
        'n_page': 5,
        'page_offset': 1,
        'problems': [
            {
                'type': 'addition',
                'operands': [1, 1],
                'questions_per_page': 10,
                'easymode': False
            }
        ]
    }


def name_to_filename(name):
    """Convert worksheet name to a valid filename."""
    # Replace spaces and special characters with underscores
    filename = re.sub(r'[^\w\s-]', '', name)  # Remove special chars except spaces and hyphens
    filename = re.sub(r'[\s]+', '_', filename)  # Replace spaces with underscores
    filename = filename.strip('_').lower()
    if not filename:
        filename = "worksheet"
    return filename


def render_worksheet_config(idx, worksheet):
    """Render the configuration UI for a single worksheet."""
    # Basic settings
    col1, col2, col3 = st.columns(3)
    
    with col1:
        worksheet['name'] = st.text_input(
            t("worksheet_name_label"),
            value=worksheet['name'],
            key=f"name_{idx}",
            help=t("worksheet_name_help")
        )
    
    with col2:
        worksheet['n_page'] = st.number_input(
            t("num_pages_label"),
            min_value=1,
            max_value=100,
            value=worksheet['n_page'],
            key=f"pages_{idx}",
            help=t("num_pages_help")
        )
    
    with col3:
        worksheet['page_offset'] = st.number_input(
            t("start_page_label"),
            min_value=1,
            max_value=1000,
            value=worksheet['page_offset'],
            key=f"offset_{idx}",
            help=t("start_page_help")
        )
    
    # Problem types
    st.markdown(f"### {t('problem_types_header')}")
    st.markdown(t("problem_types_desc"))
    
    # Add problem type button
    if st.button(t("add_problem_type"), key=f"add_problem_{idx}"):
        worksheet['problems'].append({
            'type': 'addition',
            'operands': [1, 1],
            'questions_per_page': 5,
            'easymode': False
        })
        st.rerun()
    
    # Display each problem type
    problems_to_remove = []
    for p_idx, problem in enumerate(worksheet['problems']):
        st.markdown(f"#### {t('problem_type_n')} {p_idx + 1}")
        
        col1, col2, col3, col4 = st.columns([2, 2, 2, 1])
        
        with col1:
            problem_types = {
                t("addition"): "addition",
                t("subtraction"): "subtraction",
                t("multiplication"): "multiplication",
                t("division"): "division"
            }
            
            selected_type = st.selectbox(
                t("type_label"),
                options=list(problem_types.keys()),
                index=list(problem_types.values()).index(problem['type']),
                key=f"type_{idx}_{p_idx}"
            )
            problem['type'] = problem_types[selected_type]
        
        with col2:
            col2a, col2b = st.columns(2)
            with col2a:
                first_digits = st.number_input(
                    t("first_digits_label"),
                    min_value=1,
                    max_value=5,
                    value=problem['operands'][0],
                    key=f"op1_{idx}_{p_idx}",
                    help=t("first_digits_help")
                )
            with col2b:
                second_digits = st.number_input(
                    t("second_digits_label"),
                    min_value=1,
                    max_value=5,
                    value=problem['operands'][1],
                    key=f"op2_{idx}_{p_idx}",
                    help=t("second_digits_help")
                )
            problem['operands'] = [first_digits, second_digits]
        
        with col3:
            problem['questions_per_page'] = st.number_input(
                t("questions_per_page_label"),
                min_value=1,
                max_value=50,
                value=problem['questions_per_page'],
                key=f"qpp_{idx}_{p_idx}",
                help=t("questions_per_page_help")
            )
            
            # Easy mode for subtraction and division
            if problem['type'] in ['subtraction', 'division']:
                problem['easymode'] = st.checkbox(
                    t("easy_mode"),
                    value=problem.get('easymode', False),
                    key=f"easy_{idx}_{p_idx}",
                    help=t("easy_mode_help")
                )
            else:
                problem['easymode'] = False
        
        with col4:
            st.markdown("<br>", unsafe_allow_html=True)
            if len(worksheet['problems']) > 1:
                if st.button("🗑️", key=f"del_prob_{idx}_{p_idx}"):
                    problems_to_remove.append(p_idx)
    
    # Remove marked problems
    for p_idx in reversed(problems_to_remove):
        worksheet['problems'].pop(p_idx)
    if problems_to_remove:
        st.rerun()
    
    # Delete worksheet button
    st.markdown("---")
    if len(st.session_state.worksheets) > 1:
        if st.button(t("delete_worksheet"), key=f"del_ws_{idx}"):
            st.session_state.worksheets.pop(idx)
            st.rerun()


def generate_worksheets(generate_pdf):
    """Generate all configured worksheets."""
    if not st.session_state.worksheets:
        st.error(t("no_worksheets_error"))
        return
    
    generated_files = {}
    
    progress_bar = st.progress(0)
    status_text = st.empty()
    
    total_steps = len(st.session_state.worksheets) * (2 if generate_pdf else 1)
    current_step = 0
    
    for worksheet in st.session_state.worksheets:
        status_text.text(f"{t('generating')} {worksheet['name']}...")
        
        # Build config for generator
        config = {
            'n_page': worksheet['n_page'],
            'page_offset': worksheet['page_offset'],
            'problems': worksheet['problems']
        }
        
        try:
            # Generate LaTeX
            latex_content = generate_latex(config)
            base_filename = name_to_filename(worksheet['name'])
            tex_filename = base_filename + '.tex'
            
            generated_files[tex_filename] = latex_content
            current_step += 1
            progress_bar.progress(current_step / total_steps)
            
            # Generate PDF if requested
            if generate_pdf:
                status_text.text(t("converting_to_pdf", name=worksheet['name']))
                
                success, result = compile_tex_with_texlivenet(latex_content)
                
                if success:
                    pdf_filename = base_filename + '.pdf'
                    generated_files[pdf_filename] = result
                    st.success(t("pdf_generated", name=worksheet['name']))
                else:
                    st.error(t("pdf_failed", name=worksheet['name'], error=result))
                
                current_step += 1
                progress_bar.progress(current_step / total_steps)
            
        except Exception as e:
            st.error(t("error_generating", name=worksheet['name'], error=str(e)))
            # Increment step anyway to keep progress bar moving
            current_step += (2 if generate_pdf else 1)
            progress_bar.progress(current_step / total_steps)
    
    progress_bar.progress(1.0)
    status_text.text(t("all_done"))
    
    # Create download buttons
    st.markdown("---")
    st.markdown(f"### {t('download_header')}")
    
    if len(generated_files) == 1:
        # Single file download
        filename, content = list(generated_files.items())[0]
        mime = "application/pdf" if filename.endswith('.pdf') else "text/plain"
        st.download_button(
            label=t("download_file", filename=filename),
            data=content,
            file_name=filename,
            mime=mime
        )
    else:
        # Multiple files - offer individual downloads and zip
        col1, col2 = st.columns(2)
        
        with col1:
            # Create zip file
            zip_buffer = create_zip_from_files(generated_files)
            st.download_button(
                label=t("download_all_zip"),
                data=zip_buffer,
                file_name="math_worksheets.zip",
                mime="application/zip"
            )
        
        with col2:
            st.markdown(t("individual_files"))
        
        # Individual file downloads
        for filename, content in generated_files.items():
            mime = "application/pdf" if filename.endswith('.pdf') else "text/plain"
            st.download_button(
                label=f"⬇️ {filename}",
                data=content,
                file_name=filename,
                mime=mime,
                key=f"dl_{filename}"
            )
    
    st.balloons()


if __name__ == "__main__":
    main()
