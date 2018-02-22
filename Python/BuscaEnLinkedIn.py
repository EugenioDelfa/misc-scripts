import os, time
import random
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
import pprint

def scrollDown(browser):
	'''
		Scroll (p'abajo) para paginas "cool" que tiran de JQuery y carga dinamica
	'''
	SCROLL_PAUSE_TIME = 0.5
	last_height = browser.execute_script("return document.body.scrollHeight")
	while True:
		browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
		time.sleep(SCROLL_PAUSE_TIME)
		new_height = browser.execute_script("return document.body.scrollHeight")
		if new_height == last_height:
			break
		last_height = new_height	

def buscaPersonas(page):
	'''
		Nombre y Descripcion de los kurritos
	'''
	time.sleep(random.uniform(2.0,4.0))
	perfiles = []
	for usuario in page.findAll("li", { "class" : "search-result search-result__occluded-item ember-view" }):
		perfil = {}
		try:
			nombre     = usuario.find("span", { "class" : "name actor-name" })
			anotacion1 = usuario.find("p",    { "class" : "subline-level-1 Sans-15px-black-85% search-result__truncate" })
			anotacion2 = usuario.find("p",    { "class" : "subline-level-2 Sans-13px-black-55% search-result__truncate"})
			actual     = usuario.find("p",    { "class" : "search-result__snippets mt2 Sans-13px-black-55% ember-view"})
			avatar     = usuario.find("img",  { "class" : "lazy-image loaded"})
			ruta     = usuario.find("a",    { "class" : "search-result__result-link ember-view"})
			if nombre is not None: perfil['Nombre'] = u''+nombre.text
			if anotacion1 is not None: perfil['Anotacion1'] = u''+anotacion1.text
			if anotacion2 is not None: perfil['Anotacion2'] = u''+anotacion2.text
			if actual is not None: perfil['Actual'] = u''+actual.text
			if avatar is not None: perfil['Avatar'] = avatar.get('src')
			if ruta is not None: perfil['Perfil'] = ruta.get('href')
			perfiles.append(perfil)
		except Exception, e:
			pass
	return perfiles
	
def automatizaBusqueda(browser, idEmpresa):
	'''
		Run boy run
	'''
	time.sleep(random.uniform(2.0,4.0))
	pagina = 1
	while True:
		browser.get("https://www.linkedin.com/search/results/people/?facetCurrentCompany=[%22" + str(idEmpresa) + "%22]&page=" + str(pagina))	
		scrollDown(browser)
		page = BeautifulSoup(browser.page_source, "html.parser")
		personas = buscaPersonas(page)	
		if len(personas) == 0: break
		pprint.pprint(personas)
		pagina += 1

def principal(usuario, password, empresa):
	browser = webdriver.Firefox()
	browser.get("https://linkedin.com/uas/login")
	emailElement = browser.find_element_by_id("session_key-login")
	emailElement.send_keys(usuario)
	passElement = browser.find_element_by_id("session_password-login")
	passElement.send_keys(password)
	passElement.submit()
	os.system('cls')
	print "[+] Que si! Tas dentro, a cotillear..."
	automatizaBusqueda(browser, empresa)
	browser.close()
		
if __name__ == "__main__":
	empresa  = 1449132 # Use your target company ID N (en casa del herrero, patada en los cojones)
	usuario  = '' # Tu usuario en l1nk3d1n
	password = '' # Tu pwd admin1234
	principal(usuario, password, empresa)
