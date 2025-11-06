import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// A form field that lets user pick a local file and (optionally) uploads it
/// using [onLocalPicked], then writes the returned HTTPS URL into [controller].
///
/// Form field value = the final URL (https://...) if [onLocalPicked] is provided
/// and upload succeeds; otherwise it will be the local path (not recommended if
/// your backend requires an http(s) URL).
class FilePickerFormField extends FormField<String?> {
  FilePickerFormField({
    Key? key,
    String? initialValue,
    this.controller,
    this.allowedExtensions,
    this.allowMultiple = false,
    this.onChanged,
    this.onLocalPicked, // <-- NEW: upload callback returning URL
    this.pickButtonText = 'Chọn tệp & Upload',
    this.hintWhenEmpty = 'Chọn tệp tại đây',
    this.labelWhenSelected = 'Đã chọn',
    FormFieldSetter<String?>? onSaved,
    FormFieldValidator<String?>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    EdgeInsetsGeometry? padding,
  }) : super(
         key: key,
         initialValue: initialValue,
         onSaved: onSaved,
         validator: validator,
         autovalidateMode: autovalidateMode,
         builder: (state) {
           final w = state.widget as FilePickerFormField;
           final theme = Theme.of(state.context);
           final cs = theme.colorScheme;
           final isError = state.hasError;
           final hasValue = (state.value ?? '').isNotEmpty;

           // Pull some locals from _FieldState via state (set in createState)
           final _FilePickerFieldState? ext =
               (state as dynamic) is _FilePickerFieldState
               ? (state as dynamic)
               : null;

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Pick/upload button
               InkWell(
                 onTap: ext?._uploading == true
                     ? null
                     : () async {
                         await ext?._pickAndMaybeUpload(state);
                       },
                 child: Container(
                   padding:
                       padding ??
                       const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                   decoration: BoxDecoration(
                     border: Border.all(
                       color: isError ? cs.error : theme.dividerColor,
                     ),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Center(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         if (ext?._uploading == true) ...[
                           const SizedBox(
                             height: 20,
                             width: 20,
                             child: CircularProgressIndicator(strokeWidth: 2),
                           ),
                           const SizedBox(height: 8),
                           const Text('Đang tải lên...'),
                         ] else ...[
                           Icon(
                             Icons.cloud_upload_outlined,
                             size: 28,
                             color: isError ? cs.error : null,
                           ),
                           const SizedBox(height: 6),
                           Text(
                             hasValue
                                 ? '${w.labelWhenSelected}: ${_shortenName(state.value!)}'
                                 : w.hintWhenEmpty,
                             style: TextStyle(color: isError ? cs.error : null),
                             textAlign: TextAlign.center,
                           ),
                           if (!hasValue) ...[
                             const SizedBox(height: 6),
                             Text(
                               w.pickButtonText,
                               style: TextStyle(
                                 color: cs.primary,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ],
                         ],
                       ],
                     ),
                   ),
                 ),
               ),

               // Selected value row + clear button
               if (hasValue) ...[
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Expanded(
                       child: Text(
                         state.value!,
                         style: theme.textTheme.bodySmall,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     IconButton(
                       tooltip: 'Xóa',
                       icon: const Icon(Icons.clear),
                       onPressed: ext?._uploading == true
                           ? null
                           : () {
                               state.didChange(null);
                               w.controller?.clear();
                               w.onChanged?.call(null);
                               ext?._localFileName = null;
                             },
                     ),
                   ],
                 ),
               ],

               // Error text
               if (state.hasError) ...[
                 const SizedBox(height: 6),
                 Text(
                   state.errorText ?? '',
                   style: TextStyle(color: cs.error, fontSize: 12),
                 ),
               ],
             ],
           );
         },
       );

  /// When provided, after picking a local file this callback will be awaited.
  /// It should upload the file and return a public https URL.
  /// Example signature:
  ///   Future<String> Function(String localPath)
  final Future<String> Function(String localPath)? onLocalPicked;

  /// Writes the final URL into this controller (and into form field value)
  final TextEditingController? controller;

  /// File extensions allowed (e.g. ['pdf','doc','docx'])
  final List<String>? allowedExtensions;

  /// Multi-pick is not supported together with upload here; left for future
  final bool allowMultiple;

  /// Called when the field value changes (url or path)
  final ValueChanged<String?>? onChanged;

  /// UI strings
  final String pickButtonText;
  final String hintWhenEmpty;
  final String labelWhenSelected;

  @override
  FormFieldState<String?> createState() => _FilePickerFieldState();

  static String _shortenName(String s, [int max = 36]) {
    if (s.length <= max) return s;
    return '${s.substring(0, max - 3)}...';
  }
}

class _FilePickerFieldState extends FormFieldState<String?> {
  bool _uploading = false;
  String? _localFileName;

  FilePickerFormField get _w => widget as FilePickerFormField;

  Future<void> _pickAndMaybeUpload(FormFieldState<String?> state) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: _w.allowedExtensions == null ? FileType.any : FileType.custom,
        allowedExtensions: _w.allowedExtensions,
        allowMultiple: _w.allowMultiple,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final f = result.files.first;
      final localPath = f.path ?? '';
      _localFileName = f.name;

      if (localPath.isEmpty) {
        // fallback: show name only
        state.didChange(f.name);
        _w.controller?.text = f.name;
        _w.onChanged?.call(f.name);
        return;
      }

      // If upload callback provided => upload then set URL
      if (_w.onLocalPicked != null) {
        setState(() => _uploading = true);
        try {
          final url = await _w.onLocalPicked!(localPath);

          // Optionally validate URL here if you want strictness inside the field:
          // final ok = RegExp(r'^(https?://.+)$').hasMatch(url);
          // if (!ok) throw Exception('URL không hợp lệ trả về từ uploader');

          state.didChange(url);
          _w.controller?.text = url;
          _w.onChanged?.call(url);
        } catch (e) {
          // Keep previous value; show a SnackBar via ScaffoldMessenger if needed
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Upload thất bại: $e')));
          }
        } finally {
          if (mounted) setState(() => _uploading = false);
        }
      } else {
        // No upload callback: set local path (NOT valid for http(s)-only backend)
        state.didChange(localPath);
        _w.controller?.text = localPath;
        _w.onChanged?.call(localPath);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi chọn tệp: $e')));
    }
  }
}
