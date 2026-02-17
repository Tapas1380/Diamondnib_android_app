// app/Services/PayUService.php
namespace App\Services;

class PayUService
{
    public static function responseHash(array $post, string $salt): string
    {
        $udf = [
            $post['udf1'] ?? '', $post['udf2'] ?? '', $post['udf3'] ?? '',
            $post['udf4'] ?? '', $post['udf5'] ?? '',
        ];
        $seq = [
            $salt,
            $post['status'] ?? '',
            '', '', '', '', '', // udf6..udf10
            $udf[4], $udf[3], $udf[2], $udf[1], $udf[0],
            $post['email'] ?? '',
            $post['firstname'] ?? '',
            $post['productinfo'] ?? '',
            $post['amount'] ?? '',
            $post['txnid'] ?? '',
            $post['key'] ?? ''
        ];
        return strtolower(hash('sha512', implode('|', $seq)));
    }
}