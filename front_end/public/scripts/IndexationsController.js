import ModalController from './ModalController.js';
export default class IndexationForm {
    showErrorMessage(data) {
        this.errorDetailsTarget.querySelector(`[data-error="any-error"]`).textContent = data;
    }

    clearErrorMessage() {
        this.errorDetailsTarget.querySelector(`[data-error="any-error"]`).textContent = "";
    }

    showKnownError(key) {
        this.errorDetailsTarget.querySelector(`[data-error="${key}"]`).classList.remove('is-invisible');
    }
    hideKnownError(key) {
        this.errorDetailsTarget.querySelector(`[data-error="${key}"]`).classList.add('is-invisible');
    }

    getIndexationData(jsonData) {
        const requestOptions = {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify((jsonData))
        }

        fetch("/api/v1/indexations", requestOptions)
            .then(response => {
                this.enableSubmit();
                this.clearLoadingFromSubmit()
                if (!response.ok) {
                    return response.json().then(data => {
                        throw data;
                    });
                }
                return response.json();
            }).then(data => {
            if (data) {
                console.log("Response data:", data);
                this.showResults(jsonData, data);
            }
        }).catch(error => {
            this.enableSubmit();
            this.clearLoadingFromSubmit()
            try {
                if (typeof error === 'object') {
                    if (error.error) {
                        this.showErrorMessage(error.error);
                    } else {
                        const jsonError = error.json();
                        console.log("Error details: ", jsonError);
                        for (const key in errorObject) {
                            if (errorObject.hasOwnProperty(key)) {
                                console.log(`Errors for ${key}:`);
                                for (const errorMessage of errorObject[key]) {
                                    console.log(`${key} - ${errorMessage}`);
                                }
                            }
                        }
                        this.showErrorMessage(jsonError);
                    }
                }
            } catch (e) {
                this.showKnownError("no-data");
            }
        })
    }

    disableSubmit() {
        this.submitBtn.disabled = true;
    }

    enableSubmit() {
        this.submitBtn.disabled = false;
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
            this.setSubmitToLoading();
            this.disableSubmit();
            let jsonData = {
                "start_date": this.inputFormTarget.start_date.value,
                "signed_on": this.inputFormTarget.signed_on.value,
                "base_rent": this.inputFormTarget.base_rent.value,
                "region": this.inputFormTarget.querySelector('input[name="region"]:checked')?.value,
                "current_date": this.inputFormTarget.current_date.value
            }

            console.log(jsonData);

            this.getIndexationData(jsonData);
        } else {
            event.stopPropagation();
            const invalidFields = this.inputFormTarget.querySelectorAll(':invalid');

            invalidFields.forEach(field => {
                console.log(`Invalid field: ${field.name}`);
            });
            this.inputFormTarget.requestSubmit();
            return false;
        }
    }

    showResults(formData, apiResponse) {
        this.baseRentTarget.textContent = formData.base_rent;
        this.baseIndexTarget.textContent = apiResponse.base_index;
        this.currentIndexTarget.textContent = apiResponse.current_index;
        this.newRentTarget.textContent = apiResponse.new_rent;

        this.modalController.showModal();
    }
    clearResult() {
        this.clearErrorMessage();
        this.hideKnownError('no-data');
        this.newRentTarget.textContent = "";
        this.baseIndexTarget.textContent = "";
        this.currentIndexTarget.textContent = "";
        this.modalController.closeModal();
    }
    assignCurrentDate() {
        document.getElementById("current_date").valueAsDate = new Date();
    }

    clearCurrentDate() {
        document.getElementById("current_date").value = "";
    }

    connectTargets() {
        this.errorDetailsTarget = document.getElementById('generalErrorDetails');
        this.newRentTarget = document.getElementById("newRentTarget");
        this.baseIndexTarget = document.getElementById("baseIndexTarget");
        this.baseRentTarget = document.getElementById("baseRentTarget");
        this.currentIndexTarget = document.getElementById("currentIndexTarget");
        this.submitBtn = document.getElementById("submitBtn")
        this.inputFormTarget = document.forms[0];
        this.clearCurrentBtn = document.getElementById("clearCurrentBtn")
        this.setCurrentBtn = document.getElementById("setCurrentBtn")
    }

    connectEvents() {
        this.submitBtn.addEventListener('click', this.onsubmit.bind(this), false);
        this.clearCurrentBtn.addEventListener('click', this.clearCurrentDate.bind(this), false);
        this.setCurrentBtn.addEventListener('click', this.assignCurrentDate.bind(this), false);
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
