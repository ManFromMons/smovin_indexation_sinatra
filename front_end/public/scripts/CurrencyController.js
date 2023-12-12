export default class CurrencyController {
    changeSymbol() {
        let newCurrency = this.selectionControl.value;
        let newSymbol = this.currencySymbol.innerText;

        switch (newCurrency) {
            case "USD":
                newSymbol = "$";
                break;
            case "EUR":
                newSymbol = "€";
                break;
            case "GBP":
                newSymbol = "£";
                break;
        }

        this.currencySymbol.innerText = newSymbol;
    }

    bindEvents() {
        this.selectionControl.addEventListener("change", this.changeSymbol.bind(this));
    }

    connect(element) {
        this.currencySymbol = element.querySelector("#currency_symbol");
        this.selectionControl = element.querySelector("select");
        this.bindEvents();
    }
}
