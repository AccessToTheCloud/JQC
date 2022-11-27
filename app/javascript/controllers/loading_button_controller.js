import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  _setSpin(event) {
    this.element.innerHTML = `
				<div data-turbo-cache="false">
					<span class='spinner-border spinner-border-sm' 
							role='status' 
							aria-hidden='true'></span>
					${event.params.loadingText || ""}
			</div>
		`;
    return true;
  }

  _checkConfirm(event) {
    if (event.params.confirm) {
      // If we've got a confirm message to show
      const confirm_result = confirm(event.params.confirm);
      if (!confirm_result) {
        // Clicked no, cancel the event
        event.preventDefault();
        return false;
      }
    }
    return true;
  }

	onSaveButton(event) {
    if (!this._checkConfirm(event)) {
      return false;
    }
		if (this.element.form) {
			if (!this.element.form.reportValidity()) {
        event.preventDefault();
				return false
			}
		}
    this._setSpin(event);
  }

	onExitButton(event) {
    if (!this._checkConfirm(event)) {
      return false;
    }
    this._setSpin(event);
  }

  // Use when the button needs to submit a form
  onSubmit(event) {
    if (!this._checkConfirm(event)) {
      return false;
    }

    this._setSpin(event);
    this.element.form.submit();
    this.element.disabled = true;
  }

  onClick(event) {
    if (!this._checkConfirm(event)) {
      return false;
    }
    this._setSpin(event);
  }
}
