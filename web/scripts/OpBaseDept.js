/**
 * 用来限制基本信息模块的大区选择
 * Created by wang on 2017/2/6.
 */
$(function () {
    $.ajax({
        url: '../getDept.jsp',
        dataType: 'json',
        async: false,
        type: 'post',
        success: function (r) {
            var select = $('#dept');
            for (var i = 0; i < r.id.length; i++) {
                var option = '<option value="' + r.id[i] + '">' + r.name[i] + '</option>';
                select.append(option);
            }
        }
    });
});