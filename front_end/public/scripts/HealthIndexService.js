export default class HealthIndexService {
    static requestOptions = {
        method: "POST",
        headers: { "Content-Type": "application/json" },
    };
    static apiURL = "/api/v1/indexations";

    async fetchData(parameters) {
        let response;

        try {
            response = await fetch(
                HealthIndexService.apiURL,
                Object.assign({}, HealthIndexService.requestOptions, {
                    body: JSON.stringify(parameters),
                })
            );

            if (response.ok)
                return [true, await response.json()];
            if (response.status >= 400 && response.status < 500 )
                return [false, await response.json()];

            return [false, await response.text()];
        } catch (e) {
            throw e;
        }
    }
}
