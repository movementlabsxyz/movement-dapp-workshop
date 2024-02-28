
export function hex2a(hexx: string) {
    var hex = hexx.toString();//force conversion
    var str = '';
    for (var i = 0; i < hex.length; i += 2)
        str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
    return str;
}

export function padTo2Digits(num: Date) {
    return num.toString().padStart(2, '0');
}

export function formatDate(date: any) {
    return (
        [
            padTo2Digits(date.getDate()),
            padTo2Digits(date.getMonth() + 1),
            date.getFullYear(),
        ].join('-') +
        ' ' +
        [
            padTo2Digits(date.getHours()),
            padTo2Digits(date.getMinutes()),
            padTo2Digits(date.getSeconds()),
        ].join(':')
    );
}

export function formatAddress(address: string) {
    if (!address) return "";
    return address?.slice(2, 4) + '...' + address?.slice(-2);
}