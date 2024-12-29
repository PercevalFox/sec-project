import requests
from bs4 import BeautifulSoup
import re

def get_page_title(url):
    try:
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        title = soup.title.string if soup.title else "Titre non disponible"
        print(f"Title of the page: {title}")
    except Exception as e:
        print(f"Erreur lors de la récupération du titre : {e}")

def check_http_headers(url):
    try:
        response = requests.get(url)
        print("\n=== HTTP Headers ===")
        for header, value in response.headers.items():
            print(f"{header}: {value}")
        missing_headers = []
        if "X-Frame-Options" not in response.headers:
            missing_headers.append("X-Frame-Options (protection contre clickjacking)")
        if "Content-Security-Policy" not in response.headers:
            missing_headers.append("Content-Security-Policy (protection contre XSS)")
        if "Strict-Transport-Security" not in response.headers:
            missing_headers.append("Strict-Transport-Security (HTTPS obligatoire)")
        if missing_headers:
            print("\n=== En-têtes de sécurité manquants : ===")
            for header in missing_headers:
                print(f"- {header}")
    except Exception as e:
        print(f"Erreur lors de la vérification des en-têtes HTTP : {e}")

def detect_forms_and_test_xss(url):
    try:
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        forms = soup.find_all("form")
        print(f"\n=== Détection de formulaires : {len(forms)} trouvés ===")
        for form in forms:
            action = form.get("action")
            method = form.get("method", "get").lower()
            action_url = action if action.startswith("http") else f"{url.rstrip('/')}/{action.lstrip('/')}"
            print(f"- Formulaire trouvé : action={action_url}, method={method}")

            xss_test_payload = "<script>alert('XSS')</script>"
            if method == "post":
                data = {input_tag.get("name"): xss_test_payload for input_tag in form.find_all("input") if input_tag.get("name")}
                xss_response = requests.post(action_url, data=data)
            else:
                params = {input_tag.get("name"): xss_test_payload for input_tag in form.find_all("input") if input_tag.get("name")}
                xss_response = requests.get(action_url, params=params)

            if xss_test_payload in xss_response.text:
                print(f"!!! Vulnérabilité XSS détectée sur le formulaire à l'URL {action_url} !!!")
    except Exception as e:
        print(f"Erreur lors de la détection de formulaires : {e}")


def test_sql_injection(url):
    test_payload = "' OR '1'='1"
    try:
        response = requests.get(f"{url}?id={test_payload}")
        if "mysql" in response.text.lower() or "syntax error" in response.text.lower():
            print("\n!!! Vulnérabilité SQL Injection détectée !!!")
        else:
            print("\nPas de vulnérabilité SQL Injection détectée.")
    except Exception as e:
        print(f"Erreur lors du test SQL Injection : {e}")

if __name__ == "__main__":
    url = input("Enter URL to scan: ").strip()
    if not url.startswith("http"):
        url = "http://" + url

    print("\n=== Analyse de la page ===")
    get_page_title(url)

    print("\n=== Analyse des en-têtes HTTP ===")
    check_http_headers(url)

    print("\n=== Détection et test des formulaires pour XSS ===")
    detect_forms_and_test_xss(url)

    print("\n=== Test de vulnérabilité SQL Injection ===")
    test_sql_injection(url)

    print("\n=== Analyse terminée ===")
