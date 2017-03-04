(() => {
  class Arborist {
    constructor() {
      this.toggleButtons = document.getElementsByClassName('toggle');
      this.fileLinks = document.querySelectorAll('.file > a');
      this.dirElements = document.querySelectorAll('.directory > ul');
      this.fileViewer = document.getElementById('file-viewer');
      this.treeViewer = document.getElementById('tree-viewer');
      this.backToTreeButton = document.getElementById('show-tree');
      this.expandAllButton = document.getElementById('expand-all');
      this.collapseAllButton = document.getElementById('collapse-all');
    }

    addListeners () {
      console.log('adding listeners');
      for (var i = 0; i < this.toggleButtons.length; i++) {
        this.toggleButtons[i].onclick = (ev) => this.toggleDir(ev);
      }
      for (var i = 0; i < this.fileLinks.length; i++) {
        this.fileLinks[i].onclick = () => this.viewFile();
      }

      this.expandAllButton.onclick = () => this.expandAll();
      this.collapseAllButton.onclick = () => this.collapseAll();
      this.backToTreeButton.onclick = () => this.viewTree();
    }

    collapseAll () {
      console.log('collapsing');
      console.log(this.dirElements);
      for (var i = 0; i < this.dirElements.length; i++) {
        this.dirElements[i].classList.add("collapsed");
        this.toggleButtons[i].innerHTML = '+';
      }
    }

    expandAll () {
      console.log('expanding');
      console.log(this.dirElements);
      for (var i = 0; i < this.dirElements.length; i++) {
        this.dirElements[i].classList.remove("collapsed");
        this.toggleButtons[i].innerHTML = '-';
      }
    }

    toggleDir (ev) {
      var dir = ev.target.nextElementSibling;
      console.log(ev.target, dir, ev);
      if (dir.classList.contains('collapsed')) {
        dir.classList.remove('collapsed');
        ev.target.innerHTML = '-';
      } else {
        dir.classList.add('collapsed');
        ev.target.innerHTML = '+';
      }
    }

    viewFile () {
      this.fileViewer.classList.remove('collapsed');
      this.treeViewer.classList.add('collapsed');
    }

    viewTree () {
      this.fileViewer.classList.add('collapsed');
      this.treeViewer.classList.remove('collapsed');
    }
  }

  var t = new Arborist();
  t.addListeners();
  t.collapseAll();
  t.viewTree();
})();
