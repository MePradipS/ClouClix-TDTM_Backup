public abstract with sharing class ReloadController {
	protected ApexPages.StandardController ObjectController { get; set; }
	private String ReloadPage { get; set; }

	public ReloadController() {
		Initialize();
	}

	public ReloadController(ApexPages.StandardController controller) {
		SetController(controller);
		Initialize();
	}

	private void Initialize() { 
		ReloadPage = SetReloadPage();
	}

	public PageReference Reload() {
		PreReload();
		PageReference reloadUrl = DoReload();
		return reloadUrl;
    }

	private PageReference DoReload() {
        PageReference reloadPageReference = new PageReference(ReloadPage);
        reloadPageReference.setRedirect(true);
        return reloadPageReference;
	}

	protected virtual void PreReload() { }

	protected virtual void SetController(ApexPages.StandardController controller) {
		ObjectController = controller;
	}

	protected abstract String SetReloadPage();
}