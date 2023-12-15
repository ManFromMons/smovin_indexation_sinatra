import ModalController from "./ModalController.js";
import HealthIndexService from "./HealthIndexService.js";

export default class IndexationForm {
    showErrorMessage(data) {
        this.errorDetailsTarget.querySelector(
            `[data-error="any-error"]`
        ).textContent = data;
    }

    clearErrorMessage() {
        this.errorDetailsTarget.querySelector(
            `[data-error="any-error"]`
        ).textContent = "";
    }

    showKnownError(key) {
        this.errorDetailsTarget
            .querySelector(`[data-error="${key}"]`)
            .classList.remove("is-invisible");
    }
    hideKnownError(key) {
        this.errorDetailsTarget
            .querySelector(`[data-error="${key}"]`)
            .classList.add("is-invisible");
    }

    extractValidationErrors(errorObject) {
        for (const key in errorObject) {
            if (errorObject.hasOwnProperty(key)) {
                for (const errorMessage of errorObject[key]) {
                    console.log(`${key} - ${errorMessage}`);
                }
            }
        }
        this.showErrorMessage(jsonError);
    }

    async getIndexationData(jsonData) {
        const indexService = new HealthIndexService();
        let responseStatus, data;

        try {
            [responseStatus, data] = await indexService.fetchData(jsonData);
            if (responseStatus) {
                this.showResults(jsonData, data);
            } else {
                this.showErrorMessage(data);
            }
        } catch (e) {
            this.showKnownError("no-data");
        }
        this.enableSubmit();
        this.clearLoadingFromSubmit();
    }

    disableSubmit() {
        this.submitBtn.disabled = true;
        this.setSubmitToLoading();
    }

    enableSubmit() {
        this.submitBtn.disabled = false;
        this.clearLoadingFromSubmit();
    }

    setSubmitToLoading() {
        this.submitBtn.classList.add("is-loading");
    }
    clearLoadingFromSubmit() {
        this.submitBtn.classList.remove("is-loading");
    }

    onsubmit(event) {
        if (this.inputFormTarget.checkValidity()) {
            this.clearResult();
            this.disableSubmit();
            let jsonData = {
                start_date: this.inputFormTarget.start_date.value,
                signed_on: this.inputFormTarget.signed_on.value,
                base_rent: this.inputFormTarget.base_rent.value,
                region: this.inputFormTarget.querySelector(
                    'input[name="region"]:checked'
                )?.value,
                current_date: this.inputFormTarget.current_date.value,
            };

            this.getIndexationData(jsonData);
        } else {
            event.stopPropagation();
            this.inputFormTarget.requestSubmit();
            return false;
        }
    }

    displayResultData(baseRent, baseIndex, currentIndex, newRent) {
        this.baseRentTarget.textContent = baseRent;
        this.baseIndexTarget.textContent = baseIndex;
        this.currentIndexTarget.textContent = currentIndex;
        this.newRentTarget.textContent = newRent;
    }

    showResults(formData, apiResponse) {
        this.enableSubmit();
        this.displayResultData(
            formData.base_rent,
            apiResponse.base_index,
            apiResponse.current_index,
            apiResponse.new_rent
        );
        this.modalController.showModal();
    }
    clearResult() {
        this.clearErrorMessage();
        this.hideKnownError("no-data");
        this.modalController.closeModal();
        this.displayResultData("", "", "", "");
    }
    assignCurrentDate() {
        document.getElementById("current_date").valueAsDate = new Date();
    }

    clearCurrentDate() {
        document.getElementById("current_date").value = "";
    }

    connectTargets() {
        this.errorDetailsTarget = document.getElementById(
            "generalErrorDetails"
        );
        this.newRentTarget = document.getElementById("newRentTarget");
        this.baseIndexTarget = document.getElementById("baseIndexTarget");
        this.baseRentTarget = document.getElementById("baseRentTarget");
        this.currentIndexTarget = document.getElementById("currentIndexTarget");
        this.submitBtn = document.getElementById("submitBtn");
        this.inputFormTarget = document.forms[0];
        this.clearCurrentBtn = document.getElementById("clearCurrentBtn");
        this.setCurrentBtn = document.getElementById("setCurrentBtn");
    }

    connectEvents() {
        this.submitBtn.addEventListener(
            "click",
            this.onsubmit.bind(this),
            false
        );
        this.clearCurrentBtn.addEventListener(
            "click",
            this.clearCurrentDate.bind(this),
            false
        );
        this.setCurrentBtn.addEventListener(
            "click",
            this.assignCurrentDate.bind(this),
            false
        );
    }

    connectModal() {
        let modal = document.getElementById("resultModal");
        this.modalController = new ModalController();
        this.modalController.connect(modal);
    }

    connect() {
        this.connectTargets();
        this.connectEvents();
        this.connectModal();

        this.modalController.closeModal();
    }
}
