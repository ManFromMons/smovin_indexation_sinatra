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

            if (!response.ok) {
                if (response.type !== "basic") {
                    return [false, await response.json()];
                } else {
                    throw response.bodyUsed
                        ? await response.body.text
                        : response.statusText;
                }
            }

            return [true, await response.json()];
        } catch (e) {
            console.error(e);
            throw e;
        }

        return null;
    }
}
