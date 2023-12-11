export default class ModalController {
    modalElement = null;
    closeModal() {
        this.modalElement.classList.remove('is-active');
    }
    showModal() {
        this.modalElement.classList.add('is-active');
    }
    connect(element) {
        this.modalElement = element;
        this.closeModal();

        let btns = element.querySelectorAll('[data-action="close"]');
        btns.forEach(btn => {
           btn.addEventListener('click', this.closeModal.bind(this));
        });
    }
}
