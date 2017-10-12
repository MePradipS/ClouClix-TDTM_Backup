public abstract with sharing class RedirectController {
	private String PackageNamespace { get; set; }
	private String RedirectPage { get; set; }
	private String UrlParamters { get; set; }
	private final String LIGHTNING_THEME = 'Theme4d';
	private Boolean DoThemeRedirect { get; set; }
	protected Boolean IsLightning {
		get {
			return UserInfo.getUiThemeDisplayed() == LIGHTNING_THEME;
		}
		set;
	}

	public RedirectController() {
		Initialize();
	}

	public RedirectController(Boolean tempArg){
		Initialize();
		SetRedirectPageToTheme();
	}

	public RedirectController(ApexPages.StandardController controller) {
		SetController(controller);
		Initialize();
	}

	public RedirectController(ApexPages.StandardController controller, Boolean tempArg){
		SetController(controller);
		Initialize();
		SetRedirectPageToTheme();
	}

	private void SetNamespacePrefix() {
        String namespace = Utilities.getCurrentNamespace();
        PackageNamespace = String.isEmpty(namespace) ? '' : namespace + '__';
    }

	public PageReference Redirect() {
		String redirectUrl = '/apex/' + RedirectPage + UrlParamters;
        PageReference redirectPageReference = new PageReference(redirectUrl);
        redirectPageReference.setRedirect(true);
        return redirectPageReference;
    }

    public PageReference RedirectByTheme() {
    	PageReference redirectPageReference;
    	if (DoThemeRedirect) {
    		redirectPageReference = Redirect();
    	}
    	return redirectPageReference;
    }

	protected virtual void Initialize() {
		SetNamespacePrefix();
		RedirectPage = SetRedirectPage();
		UrlParamters = SetUrlParameters();
	}

	private void SetRedirectPageToTheme() {
		DoThemeRedirect = false;
        if (RedirectPage.endsWith('Ltng') && !IsLightning) {
            RedirectPage = RedirectPage.substring(0, RedirectPage.indexOf('Ltng'));
            DoThemeRedirect = true;
        }
        if (!RedirectPage.endsWith('Ltng') && IsLightning) {
            RedirectPage = RedirectPage + 'Ltng';
            DoThemeRedirect = true;
        }
	}

	protected virtual String GetEncodedUri(String value) {
		String encodedValue = value;
		if (!String.isEmpty(encodedValue)) {
			encodedValue = EncodingUtil.urlEncode(encodedValue, 'UTF-8');
		}
		return encodedValue;
	}

    public String getPageUrl(){
        String returnPageName = '';
        if((ApexPages.currentPage().getUrl()).contains('?')){
            returnPageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        }else{
            returnPageName = ApexPages.currentPage().getUrl();
        }
        return returnPageName;
    }

    public String getUrlParams(){
        String urlParams = '';
        Map<String, String> testMap = ApexPages.CurrentPage().getparameters();

        if(testMap != null || !testMap.isEmpty()){
            urlParams = '?';
            for (String key : testMap.keySet()) {
                urlParams+=key+'=';
                urlParams+=testMap.get(key)+'&';
            }
        }
        return urlParams.removeEnd('&');
    }

	protected virtual void SetController(ApexPages.StandardController controller) { }

	// Return a String of the url parameters for the page that the redirect should navigate to
	@TestVisible
	protected virtual String SetUrlParameters() {
		return '';
	}

	// Return the name of the page that the redirect should navigate to
	@TestVisible
    protected abstract String SetRedirectPage();
}