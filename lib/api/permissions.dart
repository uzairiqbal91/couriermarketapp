class Permissions {
  Iterable<String>? userPerms;

  Permissions(this.userPerms);

  bool can(String required) {
    return userPerms!.any((element) {
      if (element == required) return true;
      var wildcardPosition = element.indexOf('*');
      if (wildcardPosition == -1) return false;
      assert(wildcardPosition == element.length - 1, "Wildcards can only be used at the end of a permission");

      var trimmedElement = element.substring(0, element.length - 1);
      var trimmedRequired = required.substring(0, required.lastIndexOf('.') + 1);

      return trimmedElement == trimmedRequired;
    });
  }

  bool canAny(Iterable<String> any) {
    for (var perm in any) {
      if (this.can(perm)) return true;
    }
    return false;
  }

  bool canAll(Iterable<String> all) {
    for (var perm in all) {
      if (!this.can(perm)) return false;
    }
    return true;
  }
}
