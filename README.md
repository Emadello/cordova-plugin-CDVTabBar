
# cordova-plugin-CDVTabBar

This plugin adds TabBar to your Cordova Applications.
You should also install CDVNavBar plugin to work properly.


## Installation

    cordova plugin add https://github.com/Emadello/cordova-plugin-CDVTabBar.git


### Supported Platforms

- iOS

### Example
```javascript
function setupnewtabbar(taborder) {
    
    var activeTab;
    activeTab = "#" + taborder;
    
    tabbar.createItem("tab1", "Tab1", "tab1.png", {
                      onSelect: function() {
                      myName = "#tab1";
                      if (activeTab != myName) {
                      activeTab = myName;
                      showTab("index1.html");}}});
    
    tabbar.createItem("tab2", "Tab2", "tab2.png", {
                      onSelect: function() {
                      myName = "#tab2";
                      if (activeTab != myName) {
                      activeTab = myName;
                      showTab("index2.html");}}});
    
    tabbar.createItem("tab3", "Tab3", "tab3.png", {
                      onSelect: function() {
                      myName = "#tab3";
                      if (activeTab != myName) {
                      activeTab = myName;
                      showTab("index3.html");}}});
    
    tabbar.createItem("tab4", "Tab4", "tab4.png", {
                      onSelect: function() {
                      myName = "#tab4";
                      if (activeTab != myName) {
                      activeTab = myName;
                      showTab("index4.html");}}});
    
    
    tabbar.createItem("tab5", "Tab5", "tab5.png", {
                      onSelect: function() {
                      myName = "#tab5";
                      if (activeTab != myName) {
                      activeTab = myName;
                      showTab("index5.html");}}});
    
    tabbar.show()
    tabbar.showItems("tab1", "tab2", "tab3", "tab4", "tab5");
    tabbar.selectItem(taborder);
}

function showTab(page) {
    window.location = page;
}
```
