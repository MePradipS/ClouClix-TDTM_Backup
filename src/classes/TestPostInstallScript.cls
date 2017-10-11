@isTest
public class TestPostInstallScript {
  @isTest static void TestInstall() {
    PostInstall postinstall = new PostInstall();
    Test.testInstall(postinstall,  null);    
  }
    
  @isTest static void TestUpgrade() {
    PostInstall postinstall = new PostInstall();
    Test.testInstall(postinstall, new Version(99,0));
  }
}