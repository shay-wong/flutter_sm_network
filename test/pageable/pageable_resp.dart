import 'package:sm_network/sm_network.dart';

/// 分页基类
class PageableResp<T> extends BaseResp<T> {
  // ignore: public_member_api_docs
  PageableResp({
    super.code,
    super.message,
    super.data,
    super.list,
    this.pageNumber,
    this.pages,
    this.pageSize,
    this.total,
    super.status,
  });

  /// 当前页
  int? pageNumber;

  /// 总页数
  int? pages;

  /// 每页的数量
  int? pageSize;

  /// 总记录数
  int? total;

  /// 没有更多数据
  bool get noMore {
    return (pageNumber ?? 0) >= (pages ?? 0);
  }

  // ignore: public_member_api_docs
  @override
  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'pages': pages,
        'total': total,
        'list': list,
      };
}
